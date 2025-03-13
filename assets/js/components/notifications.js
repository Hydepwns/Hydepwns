/**
 * 
 * Notifications Component
 * -----------------------
 * Handles the display, animation, and auto-dismissal of notifications.
 * Notifications can be temporary or persistent, with different visual styles.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class NotificationsComponent {
  /**
   * Create a new Notifications component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `notifications-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      autoDismissMs: 5000, // Default auto-dismiss time in milliseconds
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      autoDismissTimeouts: new Map() // Map to track auto-dismiss timeouts
    };
    
    // DOM element references
    this.elements = {
      container: null,
      notifications: []
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[Notifications:${this.componentId}]`, ...args);
        }
      }
    };
  }
  
  /**
   * Initialize the component and mount it to the DOM
   * @returns {this} - For method chaining
   */
  mount() {
    // Get event manager for this component
    this.events = EventManager.registerComponent(this.componentId);
    
    // Get cleanup registry for this component
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Store container reference
    this.elements.container = this.options.container || this.options.liveViewHook?.el;
    
    if (!this.elements.container) {
      console.error('Notifications component requires a container element');
      return this;
    }
    
    // Set up notifications
    this._setupNotifications();
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Clear any pending auto-dismiss timeouts
    this._clearAllTimeouts();
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Set up notifications and auto-dismissal
   * @private
   */
  _setupNotifications() {
    // Clear existing timeouts
    this._clearAllTimeouts();
    
    // Find all notification items
    const notifications = this.elements.container.querySelectorAll('.notification-item');
    this.elements.notifications = Array.from(notifications);
    
    // Set up auto-dismiss for temporary notifications
    const autoDismissMs = parseInt(this.elements.container.dataset.autoDismiss, 10) || this.options.autoDismissMs;
    
    if (!isNaN(autoDismissMs) && autoDismissMs > 0) {
      this.elements.notifications.forEach((notification) => {
        const notificationId = notification.id.split('-notification-')[1];
        
        // Don't auto-dismiss critical notifications
        if (notification.classList.contains('border-red-500')) {
          return;
        }
        
        // Set timeout for auto-dismissal
        const timeoutId = setTimeout(() => {
          this._dismissWithAnimation(notification, notificationId);
        }, autoDismissMs);
        
        // Register timeout for cleanup
        this.cleanup.registerTimeout(timeoutId);
        
        // Store in state for management
        this._state.autoDismissTimeouts.set(notificationId, timeoutId);
      });
    }
    
    // Set up animation for new notifications
    this.elements.notifications.forEach((notification) => {
      if (!notification.dataset.animatedIn) {
        // Apply entrance animation
        notification.style.transform = 'translateX(100%)';
        notification.style.opacity = '0';
        
        // Force reflow to ensure animation works
        void notification.offsetWidth;
        
        // Animate in
        notification.style.transform = 'translateX(0)';
        notification.style.opacity = '1';
        
        // Mark as animated
        notification.dataset.animatedIn = 'true';
      }
      
      // Add click event listener to dismiss button if present
      const dismissButton = notification.querySelector('.notification-dismiss');
      if (dismissButton) {
        this.events.addEventListener(
          dismissButton,
          'click',
          (event) => {
            event.preventDefault();
            const notificationId = notification.id.split('-notification-')[1];
            this._dismissWithAnimation(notification, notificationId);
          }
        );
      }
    });
  }
  
  /**
   * Dismiss a notification with animation
   * @param {HTMLElement} notificationEl - Notification element to dismiss
   * @param {string} notificationId - ID of the notification
   * @private
   */
  _dismissWithAnimation(notificationEl, notificationId) {
    // Clear any existing timeout
    if (this._state.autoDismissTimeouts.has(notificationId)) {
      clearTimeout(this._state.autoDismissTimeouts.get(notificationId));
      this._state.autoDismissTimeouts.delete(notificationId);
    }
    
    // Animate notification out
    notificationEl.style.transform = 'translateX(100%)';
    notificationEl.style.opacity = '0';
    
    // After animation completes, trigger dismiss event
    const timeoutId = setTimeout(() => {
      if (this.options.liveViewHook) {
        this.options.liveViewHook.pushEventTo(notificationEl, 'dismiss_notification', { id: notificationId });
      }
    }, 300);
    
    // Register timeout for cleanup
    this.cleanup.registerTimeout(timeoutId);
  }
  
  /**
   * Clear all auto-dismiss timeouts
   * @private
   */
  _clearAllTimeouts() {
    this._state.autoDismissTimeouts.forEach((timeoutId) => {
      clearTimeout(timeoutId);
    });
    this._state.autoDismissTimeouts.clear();
  }
  
  /**
   * Update component to handle new or changed notifications
   * Should be called when notifications are updated
   */
  update() {
    this._setupNotifications();
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const NotificationsHandler = {
  mounted() {
    this.component = new NotificationsComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    if (this.component) {
      this.component.update();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  },
  
  handleEvent(event, payload) {
    if (event === "updated_notifications" && this.component) {
      this.component.update();
    }
  }
};

export default NotificationsHandler;
export { NotificationsComponent }; 