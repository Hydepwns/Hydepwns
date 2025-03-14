# Component Migration Guide: Upgrading to the Robust Component System

This guide provides step-by-step instructions for migrating existing components to use Hydepwns' robust component system. Following these steps will ensure your components are isolated, maintainable, and properly clean up after themselves.

## Why Migrate?

The robust component system offers several key benefits:

1. **Component Isolation**: Each component has a unique ID and manages its own state.
2. **Proper Cleanup**: Components register and clean up all resources they use.
3. **Event Management**: Centralized event handling prevents memory leaks.
4. **Better Testability**: Components follow a consistent pattern that's easier to test.
5. **Improved Maintainability**: Standard structure and lifecycle methods make code more understandable.

## Migration Process Overview

1. Convert from object-based hooks to class-based components
2. Add proper initialization and cleanup methods
3. Implement the component lifecycle
4. Use EventManager for event handling
5. Use DOMCleanup for DOM manipulation
6. Maintain backward compatibility

## Step-by-Step Migration Guide

### 1. Create a Class-Based Component

Convert your object-based component to a class with a constructor, mount, and destroy methods:

```javascript
// Before (object-based hook):
const YourComponent = {
  mounted() {
    // Initialization code
  },
  
  destroyed() {
    // Cleanup code
  }
};

// After (class-based component):
class YourComponentClass {
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `your-component-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      // Add component-specific options
      ...options
    };
    
    // Component state (private)
    this._state = {
      // Component-specific state
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      root: null
      // Add component-specific elements
    };
  }
  
  mount() {
    // Initialization code
    return this;
  }
  
  destroy() {
    // Cleanup code
  }
}
```

### 2. Add EventManager and DOMCleanup Integration

Use EventManager for event handling and DOMCleanup for DOM manipulation:

```javascript
import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class YourComponentClass {
  constructor(options = {}) {
    // ... constructor code ...
  }
  
  mount() {
    // Get event manager for this component
    this.events = EventManager.registerComponent(this.componentId);
    
    // Get cleanup registry for this component
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Store reference to container
    this.elements.container = this.options.container;
    
    // Create your component's root element
    this.elements.root = DOMCleanup.createElement('div', {
      className: 'your-component',
      id: this.componentId,
      'data-component': 'your-component'
    }, '', this.cleanup);
    
    // Add to container
    this.elements.container.appendChild(this.elements.root);
    
    // Set up component's DOM structure
    this._buildDOM();
    
    // Set up event listeners
    this._setupEventListeners();
    
    return this;
  }
  
  destroy() {
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
}
```

### 3. Migrate Event Handling

Replace direct event listeners with EventManager:

```javascript
// Before:
window.addEventListener('click', this.handleClick.bind(this));

// After:
this.events.addEventListener(window, 'click', this._handleClick.bind(this));
```

For delegated events:

```javascript
// Before:
document.addEventListener('click', (e) => {
  if (e.target.matches('.selector')) {
    // Handle click
  }
});

// After:
this.events.addDelegatedEventListener(
  document,
  'click',
  '.selector',
  (event, targetElement) => {
    // Handle click on targetElement
  }
);
```

### 4. Migrate DOM Manipulation

Replace direct DOM creation with DOMCleanup:

```javascript
// Before:
const element = document.createElement('div');
element.className = 'example';
element.textContent = 'Content';
container.appendChild(element);

// After:
const element = DOMCleanup.createElement('div', {
  className: 'example'
}, 'Content', this.cleanup);
container.appendChild(element);
```

### 5. Migrate Component Initialization

Move initialization code from the mounted hook to separate methods:

```javascript
mount() {
  // Get managers and cleanup registry
  // ...
  
  // Build DOM structure and set up events
  this._buildDOM();
  this._setupEventListeners();
  
  return this;
}

_buildDOM() {
  // Create and organize DOM elements
}

_setupEventListeners() {
  // Set up event handlers
}
```

### 6. Maintain Backward Compatibility

Create a legacy hook that uses your new component:

```javascript
// Legacy LiveView hook for backward compatibility
const YourComponent = {
  mounted() {
    this.component = new YourComponentClass({
      container: this.el,
      // Pass any options needed
    }).mount();
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default YourComponent;
export { YourComponentClass };
```

## Example: Before and After

Here's an example of a simple counter component before and after migration:

### Before

```javascript
const Counter = {
  mounted() {
    this.count = 0;
    this.counterElement = this.el.querySelector('.counter-value');
    this.incrementButton = this.el.querySelector('.increment-button');
    
    this.incrementButton.addEventListener('click', () => {
      this.count += 1;
      this.counterElement.textContent = this.count;
    });
  },
  
  destroyed() {
    // No cleanup!
  }
};

export default Counter;
```

### After

```javascript
import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class CounterComponent {
  constructor(options = {}) {
    this.componentId = `counter-${Math.random().toString(36).substring(2, 9)}`;
    
    this.options = {
      container: document.body,
      initialCount: 0,
      ...options
    };
    
    this._state = {
      count: this.options.initialCount
    };
    
    this.elements = {
      container: null,
      root: null,
      counterValue: null,
      incrementButton: null
    };
  }
  
  mount() {
    this.events = EventManager.registerComponent(this.componentId);
    this.cleanup = DOMCleanup.register(this.componentId);
    
    this.elements.container = this.options.container;
    
    // For existing DOM structure
    if (this.options.useExistingDOM) {
      this.elements.root = this.elements.container;
      this.elements.counterValue = this.elements.root.querySelector('.counter-value');
      this.elements.incrementButton = this.elements.root.querySelector('.increment-button');
    } else {
      // For creating new DOM structure
      this._buildDOM();
    }
    
    this._setupEventListeners();
    this._render();
    
    return this;
  }
  
  destroy() {
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    this.elements = {};
    this._state = {};
  }
  
  increment() {
    this._setState({ count: this._state.count + 1 });
    return this;
  }
  
  _setState(newState) {
    this._state = { ...this._state, ...newState };
    this._render();
  }
  
  _buildDOM() {
    this.elements.root = DOMCleanup.createElement('div', {
      className: 'counter-component',
      id: this.componentId
    }, '', this.cleanup);
    
    this.elements.counterValue = DOMCleanup.createElement('span', {
      className: 'counter-value'
    }, this._state.count, this.cleanup);
    
    this.elements.incrementButton = DOMCleanup.createElement('button', {
      className: 'increment-button',
      type: 'button'
    }, 'Increment', this.cleanup);
    
    this.elements.root.appendChild(this.elements.counterValue);
    this.elements.root.appendChild(this.elements.incrementButton);
    
    this.elements.container.appendChild(this.elements.root);
  }
  
  _setupEventListeners() {
    this.events.addEventListener(
      this.elements.incrementButton,
      'click',
      this._handleIncrementClick.bind(this)
    );
  }
  
  _handleIncrementClick(event) {
    this.increment();
  }
  
  _render() {
    if (this.elements.counterValue) {
      this.elements.counterValue.textContent = this._state.count;
    }
  }
}

// Legacy LiveView hook for backward compatibility
const Counter = {
  mounted() {
    this.counter = new CounterComponent({
      container: this.el,
      useExistingDOM: true
    }).mount();
  },
  
  destroyed() {
    if (this.counter) {
      this.counter.destroy();
      this.counter = null;
    }
  }
};

export default Counter;
export { CounterComponent };
```

## Components Already Migrated

The following components have been migrated to the robust component system:

1. `debug_grid.js` - The Debug Grid component
2. `theme_toggle.js` - The Theme Toggle component
3. `animations.js` - Character animations and grid fade-in effects
4. `info_box.js` - The Info Box component
5. `notifications.js` - The Notifications component
6. `keyboard_navigation.js` - The Keyboard Navigation component
7. `terminal_hooks.js` - The Terminal Hooks component
8. `terminal_theme_sync.js` - The Terminal Theme Sync component
9. `copyable_code.js` - The Copyable Code component
10. `viewport_detector.js` - The Viewport Detector component
11. `ascii_art_generator.js` - The ASCII Art Generator component
12. `auto_resize.js` - The Auto Resize component for textareas

Refer to these components for real-world examples of the migration process.

## Common Challenges and Solutions

### Challenge 1: Complex Event Handling

**Problem:** Component has many event handlers with complex logic.

**Solution:** Break down event handlers into smaller, private methods and use EventManager's delegation capabilities for related elements.

### Challenge 2: External Dependencies

**Problem:** Component interacts with external libraries or APIs.

**Solution:** Register cleanup functions for any external resources:

```javascript
// For external library initialization
const externalLib = ExternalLibrary.init(element);

// Register cleanup
this.cleanup.registerCleanupFunction(() => {
  if (externalLib && typeof externalLib.destroy === 'function') {
    externalLib.destroy();
  }
});
```

### Challenge 3: Timer Management

**Problem:** Component uses timers or intervals that need cleanup.

**Solution:** Use the cleanup registry:

```javascript
const intervalId = setInterval(() => {
  // Do something
}, 1000);

this.cleanup.registerInterval(intervalId);
```

### Challenge 4: Maintaining Component State

**Problem:** Converting global or module-level state to component state.

**Solution:** Use the `_state` object and a `_setState` method:

```javascript
_setState(newState) {
  const prevState = { ...this._state };
  this._state = { ...this._state, ...newState };
  
  // Only re-render if something changed
  if (JSON.stringify(prevState) !== JSON.stringify(this._state)) {
    this._render();
  }
}
```

## Testing Migrated Components

After migration, test your component for:

1. **Isolation:** Component should work correctly when multiple instances exist
2. **Cleanup:** No memory leaks or orphaned elements after destroy
3. **Event Handling:** Events should work correctly and clean up on destruction
4. **State Management:** Component state should update correctly

## Need Help?

If you need assistance migrating a component, refer to:

1. The [COMPONENT_IMPLEMENTATION_PATTERNS.md](../../../docs/COMPONENT_IMPLEMENTATION_PATTERNS.md) document
2. Examples of migrated components mentioned above
3. The ROBUST_IMPLEMENTATION.md documentation in the PRD
