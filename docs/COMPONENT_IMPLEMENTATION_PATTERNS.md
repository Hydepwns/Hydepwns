# Component Implementation Patterns

This document provides example patterns and best practices for implementing components using Hydepwns' robust component system. Following these patterns ensures components are isolated, maintainable, and properly clean up after themselves.

## Basic Component Structure

Every component should follow this basic structure:

```javascript
/**
 * Example Component
 * 
 * Description of what this component does and its purpose.
 */

import EventManager from '../components/event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class ExampleComponent {
  /**
   * Create a new instance of ExampleComponent
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `example-component-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      theme: 'light',
      initialState: {},
      ...options
    };
    
    // Component state (private)
    this._state = {
      isVisible: false,
      isExpanded: false,
      ...this.options.initialState
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      root: null
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
    
    // Create the component's root element
    this.elements.root = DOMCleanup.createElement('div', {
      className: 'example-component',
      id: this.componentId,
      'data-component': 'example'
    }, '', this.cleanup);
    
    // Add the root element to the container
    this.elements.container = this.options.container;
    this.elements.container.appendChild(this.elements.root);
    
    // Set up component's DOM structure
    this._buildDOM();
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Trigger mounted lifecycle method
    this._onMounted();
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    // Run any pre-destruction logic
    this._onBeforeDestroy();
    
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
   * Show the component
   * @returns {this} - For method chaining
   */
  show() {
    if (this.elements.root) {
      this.elements.root.style.display = '';
      this._setState({ isVisible: true });
    }
    return this;
  }
  
  /**
   * Hide the component
   * @returns {this} - For method chaining
   */
  hide() {
    if (this.elements.root) {
      this.elements.root.style.display = 'none';
      this._setState({ isVisible: false });
    }
    return this;
  }
  
  /**
   * Update component state and trigger re-render
   * @param {Object} newState - State changes to apply
   * @private
   */
  _setState(newState) {
    const prevState = { ...this._state };
    this._state = { ...this._state, ...newState };
    
    // Only re-render if something changed
    if (JSON.stringify(prevState) !== JSON.stringify(this._state)) {
      this._render();
    }
  }
  
  /**
   * Build the initial DOM structure
   * @private
   */
  _buildDOM() {
    // Example of building DOM structure
    const header = DOMCleanup.createElement('div', {
      className: 'example-component__header',
    }, 'Example Component', this.cleanup);
    
    const content = DOMCleanup.createElement('div', {
      className: 'example-component__content',
    }, 'Content goes here', this.cleanup);
    
    const footer = DOMCleanup.createElement('div', {
      className: 'example-component__footer',
    }, '', this.cleanup);
    
    const button = DOMCleanup.createElement('button', {
      className: 'example-component__button',
      type: 'button'
    }, 'Click Me', this.cleanup);
    
    // Store references to elements we'll need to update later
    this.elements.header = header;
    this.elements.content = content;
    this.elements.button = button;
    
    // Assemble the component
    footer.appendChild(button);
    this.elements.root.appendChild(header);
    this.elements.root.appendChild(content);
    this.elements.root.appendChild(footer);
    
    // Initial render based on state
    this._render();
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    // Example of using the event manager to register a click handler
    this.events.addEventListener(this.elements.button, 'click', this._handleButtonClick.bind(this));
    
    // Example of delegated event listener
    this.events.addDelegatedEventListener(
      this.elements.root,
      'click',
      '.example-component__clickable',
      this._handleItemClick.bind(this)
    );
    
    // Example of registering a window resize handler
    this.events.addEventListener(window, 'resize', this._handleResize.bind(this));
    
    // Example of setting up a timer and registering it for cleanup
    const intervalId = setInterval(this._tick.bind(this), 1000);
    this.cleanup.registerInterval(intervalId);
  }
  
  /**
   * Render the component based on current state
   * @private
   */
  _render() {
    if (!this.elements.root) return;
    
    // Update element visibility
    this.elements.root.style.display = this._state.isVisible ? '' : 'none';
    
    // Update content based on expanded state
    if (this._state.isExpanded) {
      this.elements.content.textContent = 'Expanded content with more details';
      this.elements.button.textContent = 'Collapse';
    } else {
      this.elements.content.textContent = 'Content goes here';
      this.elements.button.textContent = 'Expand';
    }
    
    // Apply theme
    this.elements.root.setAttribute('data-theme', this.options.theme);
  }
  
  /**
   * Handle button click events
   * @param {Event} event - The click event
   * @private
   */
  _handleButtonClick(event) {
    event.preventDefault();
    this._setState({ isExpanded: !this._state.isExpanded });
  }
  
  /**
   * Handle delegated clicks on items
   * @param {Event} event - The click event
   * @param {HTMLElement} targetElement - The target element matching the selector
   * @private
   */
  _handleItemClick(event, targetElement) {
    console.log('Item clicked:', targetElement);
  }
  
  /**
   * Handle window resize events
   * @private
   */
  _handleResize() {
    console.log('Window resized');
  }
  
  /**
   * Periodic task example
   * @private
   */
  _tick() {
    console.log('Tick');
  }
  
  /**
   * Lifecycle hook called after the component is mounted
   * @private
   */
  _onMounted() {
    console.log(`Component ${this.componentId} mounted`);
  }
  
  /**
   * Lifecycle hook called before the component is destroyed
   * @private
   */
  _onBeforeDestroy() {
    console.log(`Component ${this.componentId} will be destroyed`);
  }
}

export default ExampleComponent;
```

## Component CSS Pattern

For each component, create a dedicated SCSS file that follows these conventions:

```scss
/**
 * Example Component Styles
 */

// Import theme variables
@import '../variables/theme';
@import '../variables/z-index';

// Component root with namespaced classes
.example-component {
  // Use CSS variables for theming
  background-color: var(--color-bg-secondary);
  color: var(--color-text-primary);
  border: var(--border-width) solid var(--color-border);
  border-radius: var(--border-radius-md);
  padding: var(--spacing-md);
  margin-bottom: var(--spacing-md);
  
  // Apply z-index from the standardized system
  z-index: var(--z-index-ui-base);
  
  // Proper positioning
  position: relative;
  
  // Transitions
  transition: 
    background-color var(--transition-normal),
    color var(--transition-normal),
    border-color var(--transition-normal);
  
  // Theme support
  &[data-theme="dark"] {
    background-color: var(--color-bg-tertiary);
  }
  
  // Nested components with BEM naming
  &__header {
    font-weight: bold;
    margin-bottom: var(--spacing-md);
    padding-bottom: var(--spacing-sm);
    border-bottom: var(--border-width) solid var(--color-border-light);
  }
  
  &__content {
    min-height: 100px;
    padding: var(--spacing-sm);
  }
  
  &__footer {
    margin-top: var(--spacing-md);
    text-align: right;
  }
  
  &__button {
    background-color: var(--color-button-bg);
    color: var(--color-button-text);
    border: none;
    border-radius: var(--border-radius-sm);
    padding: var(--spacing-sm) var(--spacing-md);
    cursor: pointer;
    transition: background-color var(--transition-fast);
    
    &:hover {
      background-color: var(--color-button-hover-bg);
    }
    
    &:focus {
      outline: none;
      box-shadow: 0 0 0 2px var(--color-input-focus-shadow);
    }
  }
  
  // States
  &.is-expanded {
    .example-component__content {
      border: var(--border-width) solid var(--color-border-light);
    }
  }
  
  // Responsive design
  @media (max-width: 768px) {
    padding: var(--spacing-sm);
    
    &__footer {
      text-align: center;
    }
  }
}
```

## Usage Example

Here's how to use your component in a LiveView context:

```javascript
// In your LiveView hook
const Hooks = {
  ExampleComponentHook: {
    mounted() {
      // Initialize the component when the hook element is mounted
      this.component = new ExampleComponent({
        container: this.el,
        theme: document.documentElement.dataset.theme || 'light',
        initialState: {
          isExpanded: true
        }
      }).mount();
      
      // Handle LiveView events
      this.handleEvent('toggle_component', () => {
        if (this.component) {
          if (this.component._state.isVisible) {
            this.component.hide();
          } else {
            this.component.show();
          }
        }
      });
    },
    
    updated() {
      // Handle updates from the server
      if (this.component) {
        // Update component options if needed
        this.component.options.theme = document.documentElement.dataset.theme || 'light';
        // Force a re-render
        this.component._render();
      }
    },
    
    destroyed() {
      // Clean up the component when the hook is destroyed
      if (this.component) {
        this.component.destroy();
        this.component = null;
      }
    }
  }
};

export default Hooks;
```

## Component Testing Pattern

For each component, create a test file that verifies isolation and cleanup:

```javascript
import ExampleComponent from '../assets/js/components/example_component';

describe('ExampleComponent', () => {
  let component;
  let container;
  
  beforeEach(() => {
    // Set up a clean container for each test
    container = document.createElement('div');
    document.body.appendChild(container);
  });
  
  afterEach(() => {
    // Clean up after each test
    if (component) {
      component.destroy();
      component = null;
    }
    
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
      container = null;
    }
    
    // Verify no event listeners are left behind
    const eventListenerCount = getEventListenerCount();
    expect(eventListenerCount).toBe(0);
  });
  
  it('should initialize with default options', () => {
    component = new ExampleComponent().mount();
    expect(component.elements.root).toBeTruthy();
    expect(component.options.theme).toBe('light');
  });
  
  it('should accept custom options', () => {
    component = new ExampleComponent({
      theme: 'dark',
      initialState: { isExpanded: true }
    }).mount();
    
    expect(component.options.theme).toBe('dark');
    expect(component._state.isExpanded).toBe(true);
  });
  
  it('should toggle visibility', () => {
    component = new ExampleComponent({ container }).mount();
    
    // Default should be visible
    expect(component._state.isVisible).toBe(false);
    expect(component.elements.root.style.display).toBe('none');
    
    // Show
    component.show();
    expect(component._state.isVisible).toBe(true);
    expect(component.elements.root.style.display).toBe('');
    
    // Hide
    component.hide();
    expect(component._state.isVisible).toBe(false);
    expect(component.elements.root.style.display).toBe('none');
  });
  
  it('should handle button clicks', () => {
    component = new ExampleComponent({ container }).mount();
    
    // Initial state
    expect(component._state.isExpanded).toBe(false);
    expect(component.elements.button.textContent).toBe('Expand');
    
    // Click the button
    component.elements.button.click();
    
    // State should be updated
    expect(component._state.isExpanded).toBe(true);
    expect(component.elements.button.textContent).toBe('Collapse');
  });
  
  it('should properly clean up on destroy', () => {
    component = new ExampleComponent({ container }).mount();
    
    // Store references for verification
    const rootId = component.componentId;
    const rootElement = component.elements.root;
    
    // Verify component is in the DOM
    expect(container.contains(rootElement)).toBe(true);
    
    // Destroy the component
    component.destroy();
    
    // Component should be removed from the DOM
    expect(container.contains(rootElement)).toBe(false);
    
    // Component state should be cleared
    expect(Object.keys(component._state).length).toBe(0);
    expect(Object.keys(component.elements).length).toBe(0);
  });
});
```

## Best Practices Summary

1. **Component Isolation**
   - Generate unique component IDs for every instance
   - Encapsulate state within the component
   - Use namespaced CSS classes
   - Provide clear public API methods

2. **Event Management**
   - Always use EventManager for event listeners
   - Prefer delegated events for lists and grids
   - Keep event handlers bound to the component context
   - Remove all event listeners on component destruction

3. **DOM Cleanup**
   - Register all created elements with DOMCleanup
   - Clean up timers, intervals, and event emitters
   - Implement proper lifecycle methods
   - Always call destroy() when removing components

4. **CSS Best Practices**
   - Use BEM naming for component classes
   - Utilize theme variables for consistent styling
   - Apply z-index values from the standardized system
   - Support light and dark modes

5. **State Management**
   - Keep component state private
   - Provide methods to update state
   - Re-render on state changes
   - Support event-driven updates

6. **Testing**
   - Test component isolation
   - Verify proper cleanup
   - Test all public API methods
   - Validate state transitions

By following these patterns, you'll create robust components that work reliably, clean up properly, and maintain isolation from other parts of the application. 