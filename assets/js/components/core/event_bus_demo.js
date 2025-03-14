/**
 * EventBus and Component System Demo
 * 
 * This file demonstrates how to use the EventBus with HydeComponent
 * in real-world scenarios, showing different patterns for component communication.
 */

import HydeComponent from './component_base';
import EventBus from './event_bus';
import { registerComponent, withContext, withTags } from './decorators';

// Enable debug mode for EventBus (in development only)
if (process.env.NODE_ENV === 'development') {
  EventBus.setDebug(true);
}

// Example 1: Basic global event communication between components
class NotificationPublisher extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Set up DOM
    this.setupUI();
  }
  
  setupUI() {
    if (!this.container) return;
    
    // Create notification button
    const button = this.createElement('button', {
      className: 'notification-trigger-btn',
      type: 'button'
    }, 'Send Notification');
    
    // Add event listener
    button.addEventListener('click', () => this.sendNotification());
    
    // Add to container
    this.container.appendChild(button);
  }
  
  sendNotification() {
    const notificationData = {
      title: 'New Notification',
      message: 'This is a test notification sent at ' + new Date().toLocaleTimeString(),
      type: 'info',
      timestamp: Date.now()
    };
    
    // Publish global event
    this.publish('notification:new', notificationData);
    this.debug.log('Notification sent', notificationData);
  }
}

class NotificationReceiver extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Set up DOM
    this.setupUI();
    
    // Subscribe to notification events
    this.subscribe('notification:new', this.handleNotification.bind(this));
  }
  
  setupUI() {
    if (!this.container) return;
    
    // Create notification container
    this.notificationList = this.createElement('div', {
      className: 'notification-list'
    });
    
    this.container.appendChild(this.notificationList);
  }
  
  handleNotification(event) {
    const { data } = event;
    
    // Create notification element
    const notification = this.createElement('div', {
      className: `notification notification-${data.type}`
    });
    
    const title = this.createElement('h4', {}, data.title);
    const message = this.createElement('p', {}, data.message);
    
    notification.appendChild(title);
    notification.appendChild(message);
    
    // Add to list
    this.notificationList.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 5000);
  }
}

// Example 2: Scoped events with context
@withContext('sidebar')
class SidebarToggle extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Set up DOM
    this.setupUI();
  }
  
  setupUI() {
    if (!this.container) return;
    
    // Create toggle button
    const button = this.createElement('button', {
      className: 'sidebar-toggle-btn',
      type: 'button'
    }, 'Toggle Sidebar');
    
    // Add event listener
    button.addEventListener('click', () => this.toggleSidebar());
    
    // Add to container
    this.container.appendChild(button);
  }
  
  toggleSidebar() {
    // Publish event in 'sidebar' scope
    this.publishInScope('sidebar', 'sidebar:toggle', {
      timestamp: Date.now()
    });
  }
}

@withContext('sidebar')
class SidebarPanel extends HydeComponent {
  constructor(options) {
    super(options);
    
    this.isOpen = false;
    
    // Set up DOM
    this.setupUI();
    
    // Subscribe to scoped events
    this.subscribeInScope('sidebar', 'sidebar:toggle', this.handleToggle.bind(this));
  }
  
  setupUI() {
    if (!this.container) return;
    
    // Add sidebar class
    this.container.classList.add('sidebar-panel');
    this.container.classList.add('closed');
  }
  
  handleToggle(event) {
    this.isOpen = !this.isOpen;
    
    if (this.isOpen) {
      this.container.classList.remove('closed');
      this.container.classList.add('open');
    } else {
      this.container.classList.remove('open');
      this.container.classList.add('closed');
    }
    
    // Publish state change event
    this.publishInScope('sidebar', 'sidebar:state-changed', {
      isOpen: this.isOpen,
      timestamp: event.timestamp
    });
  }
}

// Example 3: Direct component-to-component messaging
@registerComponent('chat-input')
class ChatInput extends HydeComponent {
  constructor(options) {
    super(options);
    
    this.outputComponentId = options.outputComponentId;
    
    // Set up DOM
    this.setupUI();
  }
  
  setupUI() {
    if (!this.container) return;
    
    // Create form
    const form = this.createElement('form', {
      className: 'chat-input-form'
    });
    
    // Create input
    this.input = this.createElement('input', {
      type: 'text',
      placeholder: 'Type a message...',
      className: 'chat-input-field'
    });
    
    // Create button
    const button = this.createElement('button', {
      type: 'submit',
      className: 'chat-submit-btn'
    }, 'Send');
    
    // Add event listener
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      this.sendMessage();
    });
    
    // Assemble form
    form.appendChild(this.input);
    form.appendChild(button);
    
    // Add to container
    this.container.appendChild(form);
  }
  
  sendMessage() {
    const message = this.input.value.trim();
    
    if (!message) return;
    
    // Send directly to output component
    if (this.outputComponentId) {
      this.sendTo(this.outputComponentId, 'chat:new-message', {
        text: message,
        sender: 'user',
        timestamp: Date.now()
      });
      
      // Clear input
      this.input.value = '';
    }
  }
}

@registerComponent('chat-output')
class ChatOutput extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Set up DOM
    this.setupUI();
  }
  
  setupUI() {
    if (!this.container) return;
    
    // Create message container
    this.messageList = this.createElement('div', {
      className: 'chat-message-list'
    });
    
    this.container.appendChild(this.messageList);
  }
  
  // Override onMessage to handle direct messages
  onMessage(message) {
    if (message.name === 'chat:new-message') {
      this.addMessageToUI(message.data);
    }
  }
  
  addMessageToUI(messageData) {
    // Create message element
    const messageElement = this.createElement('div', {
      className: `chat-message chat-message-${messageData.sender}`
    });
    
    const messageText = this.createElement('p', {}, messageData.text);
    const timestamp = this.createElement('span', {
      className: 'chat-message-time'
    }, new Date(messageData.timestamp).toLocaleTimeString());
    
    messageElement.appendChild(messageText);
    messageElement.appendChild(timestamp);
    
    // Add to list
    this.messageList.appendChild(messageElement);
    
    // Scroll to bottom
    this.messageList.scrollTop = this.messageList.scrollHeight;
  }
}

// Export demo components
export {
  NotificationPublisher,
  NotificationReceiver,
  SidebarToggle,
  SidebarPanel,
  ChatInput,
  ChatOutput
};

// Example initialization
export function initEventBusDemo() {
  // Find demo containers
  const notificationPublisherContainer = document.getElementById('notification-publisher');
  const notificationReceiverContainer = document.getElementById('notification-receiver');
  
  const sidebarToggleContainer = document.getElementById('sidebar-toggle');
  const sidebarPanelContainer = document.getElementById('sidebar-panel');
  
  const chatInputContainer = document.getElementById('chat-input');
  const chatOutputContainer = document.getElementById('chat-output');
  
  // Initialize components if containers exist
  const components = {};
  
  if (notificationPublisherContainer) {
    components.notificationPublisher = new NotificationPublisher({ debug: true })
      .mount(notificationPublisherContainer);
  }
  
  if (notificationReceiverContainer) {
    components.notificationReceiver = new NotificationReceiver({ debug: true })
      .mount(notificationReceiverContainer);
  }
  
  if (sidebarToggleContainer) {
    components.sidebarToggle = new SidebarToggle({ debug: true })
      .mount(sidebarToggleContainer);
  }
  
  if (sidebarPanelContainer) {
    components.sidebarPanel = new SidebarPanel({ debug: true })
      .mount(sidebarPanelContainer);
  }
  
  if (chatOutputContainer) {
    components.chatOutput = new ChatOutput({ debug: true })
      .mount(chatOutputContainer);
      
    // Only initialize chat input if we have the output component to send to
    if (chatInputContainer) {
      components.chatInput = new ChatInput({
        debug: true,
        outputComponentId: components.chatOutput.id
      }).mount(chatInputContainer);
    }
  }
  
  return components;
}

// Auto-initialize on DOMContentLoaded if we're in a browser context
if (typeof window !== 'undefined') {
  window.addEventListener('DOMContentLoaded', () => {
    if (document.getElementById('event-bus-demo')) {
      console.log('Initializing EventBus Demo');
      window.eventBusDemo = initEventBusDemo();
    }
  });
} 