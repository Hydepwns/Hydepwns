/**
 * Reactive State and Component Inspector Demo
 * 
 * This file demonstrates the use of the reactive state management system
 * and the component inspector for debugging and visualization.
 * 
 * Usage:
 * 1. Import this file in your application
 * 2. Add <div id="react-state-demo"></div> to your HTML
 * 3. Press Ctrl+Shift+I to toggle the Component Inspector
 */

import { 
  HydeComponent, 
  Registry, 
  Inspector 
} from './core';

/**
 * Counter component that demonstrates reactive state
 */
class CounterComponent extends HydeComponent {
  constructor(options = {}) {
    super({
      ...options,
      // Enable state history for time-travel debugging
      enableStateHistory: true,
      // Initial state
      initialState: {
        count: 0,
        items: [],
        filters: {
          showEven: true,
          showOdd: true
        }
      }
    });
    
    // Define computed property
    this.compute('filteredItems', ['items', 'filters.showEven', 'filters.showOdd'], () => {
      return this.state.items.filter(item => {
        const isEven = item.value % 2 === 0;
        if (isEven && !this.state.filters.showEven) return false;
        if (!isEven && !this.state.filters.showOdd) return false;
        return true;
      });
    });
    
    // Watch for state changes
    this.watch('count', (newValue, oldValue) => {
      this.debug.log(`Count changed from ${oldValue} to ${newValue}`);
    });
  }
  
  /**
   * Initialize the component
   */
  init() {
    // Create DOM elements
    this.elements.container = this.createElement('div', { class: 'counter-component' });
    
    this.elements.counterDisplay = this.createElement('div', { class: 'counter-display' });
    
    this.elements.controls = this.createElement('div', { class: 'counter-controls' });
    
    this.elements.incButton = this.createElement('button', { 
      class: 'counter-button', 
      text: 'Increment' 
    });
    
    this.elements.decButton = this.createElement('button', { 
      class: 'counter-button', 
      text: 'Decrement' 
    });
    
    this.elements.addItemButton = this.createElement('button', { 
      class: 'counter-button', 
      text: 'Add Item' 
    });
    
    this.elements.toggleEvenButton = this.createElement('button', { 
      class: 'counter-button', 
      text: 'Toggle Even' 
    });
    
    this.elements.toggleOddButton = this.createElement('button', { 
      class: 'counter-button', 
      text: 'Toggle Odd' 
    });
    
    this.elements.resetButton = this.createElement('button', { 
      class: 'counter-button', 
      text: 'Reset' 
    });
    
    this.elements.itemList = this.createElement('ul', { class: 'item-list' });
    
    // Add event listeners
    this.elements.incButton.addEventListener('click', () => this.increment());
    this.elements.decButton.addEventListener('click', () => this.decrement());
    this.elements.addItemButton.addEventListener('click', () => this.addItem());
    this.elements.toggleEvenButton.addEventListener('click', () => this.toggleEvenFilter());
    this.elements.toggleOddButton.addEventListener('click', () => this.toggleOddFilter());
    this.elements.resetButton.addEventListener('click', () => this.reset());
    
    // Assemble elements
    this.elements.controls.appendChild(this.elements.incButton);
    this.elements.controls.appendChild(this.elements.decButton);
    this.elements.controls.appendChild(this.elements.addItemButton);
    this.elements.controls.appendChild(this.elements.toggleEvenButton);
    this.elements.controls.appendChild(this.elements.toggleOddButton);
    this.elements.controls.appendChild(this.elements.resetButton);
    
    this.elements.container.appendChild(this.elements.counterDisplay);
    this.elements.container.appendChild(this.elements.controls);
    this.elements.container.appendChild(this.elements.itemList);
    
    // Append to container
    this.container.appendChild(this.elements.container);
    
    // Initial render
    this.render();
  }
  
  /**
   * Render the component
   */
  render() {
    // Update counter display
    this.elements.counterDisplay.textContent = `Count: ${this.state.count}`;
    
    // Update item list
    this.elements.itemList.innerHTML = '';
    
    this.state.filteredItems.forEach(item => {
      const listItem = document.createElement('li');
      listItem.textContent = `Item ${item.id}: ${item.value}`;
      this.elements.itemList.appendChild(listItem);
    });
    
    // Update filter button states
    this.elements.toggleEvenButton.textContent = 
      `${this.state.filters.showEven ? 'Hide' : 'Show'} Even`;
    
    this.elements.toggleOddButton.textContent = 
      `${this.state.filters.showOdd ? 'Hide' : 'Show'} Odd`;
  }
  
  /**
   * Increment the counter
   */
  increment() {
    this.state.count += 1;
  }
  
  /**
   * Decrement the counter
   */
  decrement() {
    this.state.count -= 1;
  }
  
  /**
   * Add a new item
   */
  addItem() {
    // Use batch update to group multiple state changes
    this.batch(() => {
      const id = this.state.items.length + 1;
      this.state.items.push({
        id,
        value: this.state.count
      });
      this.state.count += 1;
    });
  }
  
  /**
   * Toggle the "show even" filter
   */
  toggleEvenFilter() {
    this.state.filters.showEven = !this.state.filters.showEven;
  }
  
  /**
   * Toggle the "show odd" filter
   */
  toggleOddFilter() {
    this.state.filters.showOdd = !this.state.filters.showOdd;
  }
  
  /**
   * Reset all state
   */
  reset() {
    // Use transaction for atomic state changes
    this.transaction(() => {
      try {
        this.state.count = 0;
        this.state.items = [];
        this.state.filters.showEven = true;
        this.state.filters.showOdd = true;
        return true; // Commit changes
      } catch (error) {
        console.error('Reset failed:', error);
        return false; // Roll back changes
      }
    });
  }
}

/**
 * NestedComponent that demonstrates component hierarchy and inspector
 */
class NestedComponent extends HydeComponent {
  constructor(options = {}) {
    super({
      ...options,
      initialState: {
        title: options.title || 'Nested Component',
        clicks: 0
      }
    });
  }
  
  init() {
    // Create DOM elements
    this.elements.container = this.createElement('div', { 
      class: 'nested-component',
      style: 'border: 1px solid #ccc; padding: 10px; margin: 10px;'
    });
    
    this.elements.title = this.createElement('h3', { 
      text: this.state.title
    });
    
    this.elements.clickInfo = this.createElement('p', { 
      text: `Clicks: ${this.state.clicks}`
    });
    
    this.elements.clickButton = this.createElement('button', { 
      text: 'Click me'
    });
    
    // Add event listeners
    this.elements.clickButton.addEventListener('click', () => {
      this.state.clicks += 1;
      
      // Publish an event for the inspector to capture
      this.publish('component:clicked', { 
        componentId: this.id, 
        clicks: this.state.clicks 
      });
    });
    
    // Assemble elements
    this.elements.container.appendChild(this.elements.title);
    this.elements.container.appendChild(this.elements.clickInfo);
    this.elements.container.appendChild(this.elements.clickButton);
    
    // Append to container
    this.container.appendChild(this.elements.container);
    
    // Initial render
    this.render();
    
    // Subscribe to parent events
    this.subscribe('parent:message', this.onParentMessage.bind(this));
  }
  
  render() {
    this.elements.title.textContent = this.state.title;
    this.elements.clickInfo.textContent = `Clicks: ${this.state.clicks}`;
  }
  
  onParentMessage(data) {
    console.log(`[${this.id}] Received message from parent:`, data);
  }
}

/**
 * Main component that demonstrates the inspector and reactive state
 */
class DemoComponent extends HydeComponent {
  constructor(options = {}) {
    super({
      ...options,
      debug: true,
      enableStateHistory: true,
      initialState: {
        showInspectorHelp: true,
        childComponents: []
      }
    });
    
    // Children components
    this.children = [];
  }
  
  init() {
    // Create DOM elements
    this.elements.container = this.createElement('div', { 
      class: 'demo-component'
    });
    
    this.elements.header = this.createElement('h2', { 
      text: 'Reactive State & Component Inspector Demo'
    });
    
    this.elements.inspectorHelp = this.createElement('div', { 
      class: 'inspector-help',
      html: '<p>Press <strong>Ctrl+Shift+I</strong> to toggle the Component Inspector</p>'
    });
    
    this.elements.hideHelpButton = this.createElement('button', { 
      text: 'Hide Help',
      style: 'margin-bottom: 20px;'
    });
    
    this.elements.counterContainer = this.createElement('div', { 
      class: 'counter-container'
    });
    
    this.elements.nestedContainer = this.createElement('div', { 
      class: 'nested-container'
    });
    
    this.elements.addNestedButton = this.createElement('button', { 
      text: 'Add Nested Component'
    });
    
    this.elements.broadcastButton = this.createElement('button', { 
      text: 'Broadcast to Children'
    });
    
    // Add event listeners
    this.elements.hideHelpButton.addEventListener('click', () => {
      this.state.showInspectorHelp = false;
    });
    
    this.elements.addNestedButton.addEventListener('click', () => {
      this.addNestedComponent();
    });
    
    this.elements.broadcastButton.addEventListener('click', () => {
      this.broadcastToChildren();
    });
    
    // Assemble elements
    this.elements.container.appendChild(this.elements.header);
    
    if (this.state.showInspectorHelp) {
      this.elements.container.appendChild(this.elements.inspectorHelp);
      this.elements.container.appendChild(this.elements.hideHelpButton);
    }
    
    this.elements.container.appendChild(this.elements.counterContainer);
    this.elements.container.appendChild(this.elements.addNestedButton);
    this.elements.container.appendChild(this.elements.broadcastButton);
    this.elements.container.appendChild(this.elements.nestedContainer);
    
    // Append to container
    this.container.appendChild(this.elements.container);
    
    // Create counter component
    this.counter = new CounterComponent({ 
      debug: true,
      id: 'main-counter',
      parentId: this.id 
    });
    this.counter.mount(this.elements.counterContainer);
    this.counter.init();
    
    // Add initial nested components
    this.addNestedComponent();
    this.addNestedComponent();
    
    // Watch for state changes
    this.watch('showInspectorHelp', (newValue) => {
      if (!newValue) {
        this.elements.inspectorHelp.remove();
        this.elements.hideHelpButton.remove();
      }
    });
    
    // Enable Component Inspector in development
    if (process.env.NODE_ENV === 'development') {
      Inspector.UI.getInstance().enable();
      
      // Start monitoring events and performance
      Inspector.EventMonitor.getInstance().startMonitoring();
      Inspector.PerformanceMonitor.getInstance().monitorAllComponents();
    }
  }
  
  addNestedComponent() {
    const componentId = `nested-${this.state.childComponents.length + 1}`;
    const nestedComp = new NestedComponent({ 
      id: componentId,
      parentId: this.id,
      title: `Child ${this.state.childComponents.length + 1}` 
    });
    
    // Create container for nested component
    const container = document.createElement('div');
    this.elements.nestedContainer.appendChild(container);
    
    // Mount and initialize
    nestedComp.mount(container);
    nestedComp.init();
    
    // Store reference
    this.children.push(nestedComp);
    
    // Update state
    this.state.childComponents.push(componentId);
  }
  
  broadcastToChildren() {
    this.publish('parent:message', {
      from: this.id,
      message: 'Hello from parent!',
      timestamp: new Date().toISOString()
    });
  }
}

// Initialize the demo when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const demoContainer = document.getElementById('react-state-demo');
  if (demoContainer) {
    const demo = new DemoComponent({ id: 'main-demo' });
    demo.mount(demoContainer);
    demo.init();
  }
}); 