// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Import utilities
import EventManager from "./components/event_manager"
import DOMCleanup from "./utils/dom_cleanup"

// Remove CSS imports - now handled by Phoenix's built-in CSS processing

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Import component hooks
import DebugGrid from "./components/debug_grid"
import DebugGridToggle from "./hooks/debug_grid_toggle"
import ThemeToggle from "./hooks/theme_toggle"
import CopyableCode from "./hooks/copyable_code"
import KeyboardNavigation from "./hooks/keyboard_navigation"
import FocusMode from "./hooks/focus_mode"
import AsciiArtGenerator from "./hooks/ascii_art_generator"
import DiagramEditor from "./hooks/diagram_editor"
import AutoResize from "./hooks/auto_resize"
import MonoGrid from "./hooks/mono_grid"
import Terminal from "./hooks/terminal"
import LazyLoad from "./hooks/lazy_load"
import TimelineHook from "./hooks/timeline_hooks"
import ProgressIndicatorHook from "./hooks/progress_indicator_hooks"
import HierarchicalTOC from "./hooks/hierarchical_toc"
import { CharacterAnimation, GridFadeIn } from "./components/animations"
import TerminalHooks from "./hooks/terminal_hooks"
import TerminalThemeSync from "./hooks/terminal_theme_sync"
import ViewportDetector from "./hooks/viewport_detector" 
import AccessibilityMenuToggle from "./hooks/accessibility_menu_toggle"
import NotificationsHandler from "./hooks/notifications"

// Import accessibility functions
import "./accessibility/accessibility.js"

// Import style guide module
import { initStyleGuide } from "./style_guide";

// Import font optimization module
import { initFontOptimizations } from "./font-optimizations";

// Import mobile optimizations
import mobileOptimizations from "./performance/mobile_optimizations";

/**
 * Debug Utility
 * -------------
 * Provides controlled logging that only appears in development environments.
 * 
 * This utility prevents debug logs from appearing in production while maintaining
 * useful development information. All component logging should use this utility
 * instead of direct console.log calls.
 * 
 * Usage: DEBUG.log("Message", value1, value2, ...);
 */
const DEBUG = {
  enabled: window.location.hostname === 'localhost',
  log(...args) {
    if (this.enabled) console.log(...args);
  }
};

// Initialize Phoenix LiveView
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Register all component hooks
const Hooks = {
  DebugGrid,
  DebugGridToggle,
  ThemeToggle,
  CopyableCode,
  KeyboardNavigation,
  FocusMode,
  AsciiArtGenerator,
  DiagramEditor,
  AutoResize,
  MonoGrid,
  Terminal,
  CharacterAnimation,
  GridFadeIn,
  LazyLoad,
  TimelineHook,
  ProgressIndicatorHook,
  HierarchicalTOC,
  TerminalThemeSync,
  ViewportDetector,
  AccessibilityMenuToggle,
  NotificationsHandler,
  ...TerminalHooks
}

// Create LiveSocket with hooks and parameters
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      // Maintain existing theme when DOM is updated
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    }
  }
})

// Configure page loading indicators
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

/**
 * Theme System: Initial Setup
 * ---------------------------
 * This function runs immediately to set the initial theme before DOM is fully loaded,
 * which prevents a flash of unstyled content or incorrect theme on page load.
 * 
 * The theme is applied in two ways:
 * 1. As a data-theme attribute on documentElement (html tag) - This enables CSS
 *    variables to be inherited throughout the document.
 * 2. As a class on the body element - This enables class-based styling for specific
 *    elements and components.
 * 
 * The function prioritizes themes in this order:
 * 1. User's previously selected theme from localStorage
 * 2. System preference (light/dark) if no saved preference
 * 3. Light theme as fallback
 */
const setInitialTheme = () => {
  DEBUG.log("Setting initial theme on page load");
  
  // Check system preference or use saved theme
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const savedTheme = localStorage.getItem('theme') || (prefersDark ? 'dark-theme' : 'light-theme');
  
  DEBUG.log("Initial theme value", savedTheme);
  
  // Apply to document and body
  document.documentElement.setAttribute('data-theme', savedTheme);
  document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
  document.body.classList.add(savedTheme);
  
  // Log result for debugging
  DEBUG.log("Theme applied to document element:", document.documentElement.getAttribute('data-theme'));
  DEBUG.log("Theme applied to body:", document.body.className);
};

/**
 * Debounce Utility
 * ----------------
 * Returns a function that will only execute after it stops being called
 * for the specified delay period. Useful for expensive operations like
 * resize events.
 * 
 * @param {Function} func - The function to debounce
 * @param {number} delay - Delay in milliseconds
 * @return {Function} - Debounced function
 */
const debounce = (func, delay) => {
  let timeoutId;
  return (...args) => {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
    timeoutId = setTimeout(() => {
      func(...args);
    }, delay);
  };
};

// Event listeners
window.addEventListener('DOMContentLoaded', () => {
  createAccessibilityNotification();
  setInitialTheme();
  setupKeyboardDemoDialog();
  
  // Initialize style guide if present
  if (document.querySelector('.style-guide')) {
    initStyleGuide();
  }
  
  // Apply font optimizations first, before any other initialization
  // This ensures fonts are loaded efficiently
  initFontOptimizations();
});

// Setup resize handler with debouncing for performance
window.addEventListener('resize', debounce(() => {
  // Recalculate anything that needs to adjust based on window size
  // For example, recalculate line-based measurements
  const root = document.documentElement;
  const fontSizeInPx = parseFloat(window.getComputedStyle(root).fontSize);
  const lineHeightValue = parseFloat(getComputedStyle(root).getPropertyValue('--line-height'));
  
  // Update any calculations that depend on viewport size
  DEBUG.log("Window resized - font size:", fontSizeInPx, "px, line-height:", lineHeightValue);
  
  // Inform LiveView about the resize
  if (window.liveSocket) {
    window.liveSocket.execJS(document, `window.dispatchEvent(new CustomEvent("phx:resize"))`);
  }
}, 200)); // 200ms debounce delay

/**
 * Keyboard Controls and Accessibility Notification
 * -----------------------------------------------
 * Create a temporary notification to inform users about keyboard shortcuts,
 * particularly for animation controls and accessibility features.
 */
const createAccessibilityNotification = () => {
  // Only create notification if animations are likely to be present
  const hasAnimations = document.querySelector('.typewriter, .char-fade, .grid-fade-in');
  
  if (!hasAnimations) return;
  
  // Create notification element
  const notification = document.createElement('div');
  notification.className = 'keyboard-controls-notification';
  notification.setAttribute('role', 'status');
  notification.setAttribute('aria-live', 'polite');
  
  // Style the notification
  Object.assign(notification.style, {
    position: 'fixed',
    bottom: '4rem',
    right: '1rem',
    backgroundColor: 'var(--background-color-alt)',
    color: 'var(--text-color)',
    padding: '1rem',
    borderRadius: '0.5rem',
    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.15)',
    zIndex: '100',
    maxWidth: '300px',
    border: '1px solid var(--text-color-alt)',
    fontFamily: 'var(--font-family)',
    fontSize: '0.9rem',
    transform: 'translateY(20px)',
    opacity: '0',
    transition: 'transform 0.3s ease, opacity 0.3s ease'
  });
  
  // Create notification content
  notification.innerHTML = `
    <div style="margin-bottom: 0.5rem; font-weight: bold;">Keyboard Controls</div>
    <div style="margin-bottom: 0.5rem;">Alt+R: Replay animations</div>
    <button class="dismiss-btn" style="background: none; border: none; color: var(--text-color); text-decoration: underline; cursor: pointer; padding: 0;">Dismiss</button>
  `;
  
  // Add to document
  document.body.appendChild(notification);
  
  // Show the notification with a slight delay
  setTimeout(() => {
    notification.style.transform = 'translateY(0)';
    notification.style.opacity = '1';
  }, 2000);
  
  // Add event listener to dismiss button
  notification.querySelector('.dismiss-btn').addEventListener('click', () => {
    notification.style.transform = 'translateY(20px)';
    notification.style.opacity = '0';
    
    // Remove from DOM after animation completes
    setTimeout(() => {
      document.body.removeChild(notification);
    }, 300);
    
    // Remember that user has seen the notification
    localStorage.setItem('animation-controls-seen', 'true');
  });
  
  // Auto-dismiss after 10 seconds
  setTimeout(() => {
    if (document.body.contains(notification)) {
      notification.style.transform = 'translateY(20px)';
      notification.style.opacity = '0';
      
      setTimeout(() => {
        if (document.body.contains(notification)) {
          document.body.removeChild(notification);
        }
      }, 300);
    }
  }, 10000);
};

/**
 * Keyboard Navigation Demo Dialog
 * -------------------------------
 * Create a demo dialog that demonstrates keyboard navigation
 * and focus trapping features for the keyboard navigation demo.
 */
const setupKeyboardDemoDialog = () => {
  // Create dialog element if it doesn't exist
  if (!document.getElementById('keyboard-demo-dialog')) {
    const dialog = document.createElement('div');
    dialog.id = 'keyboard-demo-dialog';
    dialog.className = 'modal';
    dialog.setAttribute('role', 'dialog');
    dialog.setAttribute('aria-labelledby', 'keyboard-demo-dialog-title');
    dialog.setAttribute('aria-hidden', 'true');
    dialog.setAttribute('tabindex', '-1');
    
    // Style the dialog
    Object.assign(dialog.style, {
      display: 'none',
      position: 'fixed',
      top: '0',
      left: '0',
      width: '100%',
      height: '100%',
      backgroundColor: 'rgba(0, 0, 0, 0.5)',
      zIndex: '1000',
      overflow: 'auto'
    });
    
    // Create dialog content
    dialog.innerHTML = `
      <div class="modal-content" style="
        background-color: var(--background-color);
        color: var(--text-color);
        margin: 15% auto;
        padding: 20px;
        border: 1px solid var(--border-color);
        width: 80%;
        max-width: 500px;
        position: relative;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
      ">
        <h3 id="keyboard-demo-dialog-title">Keyboard Navigation Demo</h3>
        <p>This dialog demonstrates focus trapping. Try using Tab to navigate through the elements below:</p>
        
        <button class="dialog-demo-button" style="margin: 5px; padding: 5px 10px;">Button 1</button>
        <button class="dialog-demo-button" style="margin: 5px; padding: 5px 10px;">Button 2</button>
        <input type="text" placeholder="Text input" style="margin: 5px; padding: 5px; width: 200px;">
        <select style="margin: 5px; padding: 5px;">
          <option>Option 1</option>
          <option>Option 2</option>
        </select>
        
        <p>Press Escape to close this dialog, or click the close button:</p>
        
        <button class="modal-close" style="
          background: none;
          border: none;
          position: absolute;
          top: 10px;
          right: 10px;
          cursor: pointer;
          padding: 5px;
          font-size: 16px;
        ">✕</button>
        
        <button class="close-button" style="
          margin-top: 15px;
          padding: 5px 10px;
          background-color: var(--accent-color);
          color: var(--text-color-inverse);
          border: none;
          cursor: pointer;
        ">Close Dialog</button>
      </div>
    `;
    
    // Add to document
    document.body.appendChild(dialog);
    
    // Add event listeners to close buttons
    const closeButtons = dialog.querySelectorAll('.close-button, .modal-close');
    closeButtons.forEach(button => {
      button.addEventListener('click', () => {
        dialog.style.display = 'none';
        dialog.setAttribute('aria-hidden', 'true');
        
        // Send event to server
        if (window.liveSocket) {
          window.liveSocket.execJS(document, `window.dispatchEvent(new CustomEvent("phx:close_demo_dialog"))`);
        }
      });
    });
  }
};

// Register LiveView push event handlers
window.addEventListener("phx:show_demo_dialog", (e) => {
  const dialog = document.getElementById('keyboard-demo-dialog');
  if (dialog) {
    dialog.style.display = 'block';
    dialog.setAttribute('aria-hidden', 'false');
    
    // Let the focus trap handle focus management
  }
});

window.addEventListener("phx:hide_demo_dialog", (e) => {
  const dialog = document.getElementById('keyboard-demo-dialog');
  if (dialog) {
    dialog.style.display = 'none';
    dialog.setAttribute('aria-hidden', 'true');
  }
});

// Handle replay_animations event
window.addEventListener("phx:replay_animations", (e) => {
  // Find all elements with CharacterAnimation hook
  const characterElements = document.querySelectorAll('[phx-hook="CharacterAnimation"]');
  characterElements.forEach(element => {
    if (element.__hooks && element.__hooks.CharacterAnimation) {
      // Call the replayAnimation method if it exists
      if (typeof element.__hooks.CharacterAnimation.replayAnimation === 'function') {
        element.__hooks.CharacterAnimation.replayAnimation();
      }
    }
  });
  
  // Find all elements with GridFadeIn hook
  const gridElements = document.querySelectorAll('[phx-hook="GridFadeIn"]');
  gridElements.forEach(element => {
    if (element.__hooks && element.__hooks.GridFadeIn) {
      // Call the replayAnimation method if it exists
      if (typeof element.__hooks.GridFadeIn.replayAnimation === 'function') {
        element.__hooks.GridFadeIn.replayAnimation();
      }
    }
  });
  
  // Announce to screen readers
  const announcer = document.getElementById('accessibility-announcer');
  if (announcer) {
    announcer.textContent = 'Animations replaying';
  }
});

window.addEventListener("phx:announce", (e) => {
  const {message} = e.detail;
  const announcer = document.getElementById('accessibility-announcer');
  if (announcer) {
    announcer.textContent = message;
  }
});

window.addEventListener("phx:toggle_keyboard_help", (e) => {
  const help = document.getElementById('keyboard-help');
  if (help) {
    const isVisible = help.style.display === 'block';
    help.style.display = isVisible ? 'none' : 'block';
    
    // Announce the state change
    const announcer = document.getElementById('accessibility-announcer');
    if (announcer) {
      announcer.textContent = isVisible ? 'Keyboard help closed' : 'Keyboard help opened';
    }
  }
});

// Expose liveSocket variable for debugging
window.liveSocket = liveSocket

// Connect to LiveView
liveSocket.connect()

// Initialize mobile optimizations after the page loads
document.addEventListener('DOMContentLoaded', async () => {
  // Initialize font optimizations
  initFontOptimizations();
  
  // Initialize mobile optimizations
  await mobileOptimizations.init();
  
  // Initialize style guide if needed
  if (document.querySelector('#style-guide')) {
    initStyleGuide();
  }
});

// Configure global const for use in other modules
window.DEBUG = DEBUG;

