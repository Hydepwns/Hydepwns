/**
 * Component Decorators
 * 
 * Decorators for enhancing components with additional functionality,
 * particularly focused on automatic registration with the Component Registry.
 * 
 * Usage:
 * 
 * @registerComponent('search-box')
 * class SearchBox extends HydeComponent {
 *   // Implementation
 * }
 */

import Registry from './component_registry';

/**
 * Decorator for automatic component registration
 * Wraps a component class to register instances automatically with the Component Registry
 * 
 * @param {string} componentType - The type name for the component
 * @returns {Function} - Decorator function for the component class
 */
export function registerComponent(componentType) {
  return function(ComponentClass) {
    const originalName = ComponentClass.name;
    
    return class RegisteredComponent extends ComponentClass {
      constructor(options = {}) {
        // Call the original constructor
        super(options);
        
        // Default ID generation if not provided
        if (!this.id) {
          this.id = `${componentType}-${Math.random().toString(36).substring(2, 9)}`;
        }
        
        // Set type if not already set
        if (!this.type) {
          this.type = componentType || originalName;
        }
        
        // Auto-register with Component Registry
        Registry.register(this, this.type);
        
        // Clean up on destruction if unmount method exists
        if (typeof this.unmount === 'function') {
          const originalUnmount = this.unmount.bind(this);
          this.unmount = () => {
            // Call original unmount first
            const result = originalUnmount();
            
            // Ensure component is unregistered
            Registry.unregister(this.id);
            
            return result;
          };
        }
      }
      
      // Preserve original class name for debugging
      static get name() {
        return originalName;
      }
    };
  };
}

/**
 * Decorator for adding context to a component
 * Sets the context property for a component, useful for scoped events
 * 
 * @param {string} contextId - The context identifier
 * @returns {Function} - Decorator function for the component class
 */
export function withContext(contextId) {
  return function(ComponentClass) {
    return class ContextComponent extends ComponentClass {
      constructor(options = {}) {
        // Pass context through options
        super({
          ...options,
          context: contextId
        });
        
        // Also set context directly
        this.context = contextId;
      }
    };
  };
}

/**
 * Decorator for adding tags to a component
 * Sets the tags property for a component, useful for component querying
 * 
 * @param {...string} tags - Tags to apply to the component
 * @returns {Function} - Decorator function for the component class
 */
export function withTags(...tags) {
  return function(ComponentClass) {
    return class TaggedComponent extends ComponentClass {
      constructor(options = {}) {
        // Merge with existing tags if present
        const mergedTags = [...(options.tags || []), ...tags];
        
        super({
          ...options,
          tags: mergedTags
        });
        
        // Also set tags directly
        this.tags = mergedTags;
      }
    };
  };
}

/**
 * Decorator for enabling debug mode on a component
 * @returns {Function} - Decorator function for the component class
 */
export function debugComponent() {
  return function(ComponentClass) {
    return class DebugComponent extends ComponentClass {
      constructor(options = {}) {
        super({
          ...options,
          debug: true
        });
      }
    };
  };
}

/**
 * Helper for applying multiple decorators
 * @param {...Function} decorators - Decorators to apply
 * @returns {Function} - Combined decorator function
 */
export function composeDecorators(...decorators) {
  return function(ComponentClass) {
    return decorators.reduceRight(
      (DecoratedClass, decorator) => decorator(DecoratedClass),
      ComponentClass
    );
  };
}

// Example usage:
// const decorators = composeDecorators(
//   registerComponent('search-box'),
//   withContext('header'),
//   withTags('searchable', 'input')
// );
// 
// @decorators
// class SearchBox extends HydeComponent {
//   // Implementation
// } 