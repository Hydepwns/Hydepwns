/**
 * Component Registry
 * 
 * A centralized registry for component management, providing features like:
 * - Component registration and discovery
 * - Component querying by ID, type, context, or tags
 * - Lifecycle hooks for component mounting and unmounting
 * - Centralized component metadata storage
 * 
 * The registry is implemented as a singleton to ensure a single source of truth
 * for component information throughout the application.
 */

/**
 * Generate a unique ID for internal use
 * @returns {string} A unique identifier
 */
function generateUniqueId() {
  return Math.random().toString(36).substring(2, 9);
}

/**
 * Component Registry Singleton
 */
class ComponentRegistry {
  constructor() {
    // Singleton pattern implementation
    if (ComponentRegistry.instance) {
      return ComponentRegistry.instance;
    }
    
    // Main component storage - maps component IDs to component instances
    this._components = new Map();
    
    // Indexes for efficient lookup
    this._typeIndex = new Map();      // type -> Set of components
    this._contextIndex = new Map();   // context -> Set of components
    this._tagIndex = new Map();       // tag -> Set of components
    
    // Lifecycle event handlers
    this._mountHandlers = new Map();    // type -> Array of handlers
    this._unmountHandlers = new Map();  // type -> Array of handlers
    
    // Debug mode
    this._debug = process.env.NODE_ENV === 'development';
    
    ComponentRegistry.instance = this;
  }
  
  /**
   * Register a component with the registry
   * @param {Object} component - The component instance to register
   * @param {string} type - The component type
   * @returns {Object} - The registered component (for chaining)
   */
  register(component, type) {
    if (!component || !component.id) {
      console.error('ComponentRegistry: Cannot register component without ID');
      return null;
    }
    
    const id = component.id;
    
    // Store in main component map
    this._components.set(id, component);
    
    // Index by type
    if (!this._typeIndex.has(type)) {
      this._typeIndex.set(type, new Set());
    }
    this._typeIndex.get(type).add(component);
    
    // Index by context if available
    const context = component.context;
    if (context) {
      if (!this._contextIndex.has(context)) {
        this._contextIndex.set(context, new Set());
      }
      this._contextIndex.get(context).add(component);
    }
    
    // Index by tags if available
    const tags = component.tags || [];
    if (Array.isArray(tags)) {
      for (const tag of tags) {
        if (!this._tagIndex.has(tag)) {
          this._tagIndex.set(tag, new Set());
        }
        this._tagIndex.get(tag).add(component);
      }
    }
    
    // Trigger mount handlers for this type
    if (this._mountHandlers.has(type)) {
      const handlers = this._mountHandlers.get(type);
      for (const handler of handlers) {
        try {
          handler(component);
        } catch (error) {
          console.error(`Error in mount handler for ${type}:${id}`, error);
        }
      }
    }
    
    if (this._debug) {
      console.log(`ComponentRegistry: Registered ${type}:${id}`);
    }
    
    return component;
  }
  
  /**
   * Unregister a component from the registry
   * @param {string} componentId - The ID of the component to unregister
   * @returns {boolean} - Whether the component was successfully unregistered
   */
  unregister(componentId) {
    if (!componentId) {
      console.error('ComponentRegistry: Cannot unregister component without ID');
      return false;
    }
    
    // Get the component
    const component = this._components.get(componentId);
    if (!component) {
      if (this._debug) {
        console.warn(`ComponentRegistry: Component ${componentId} not found for unregistration`);
      }
      return false;
    }
    
    const type = component.type || component.constructor.name;
    
    // Remove from type index
    if (this._typeIndex.has(type)) {
      const typeSet = this._typeIndex.get(type);
      typeSet.delete(component);
      if (typeSet.size === 0) {
        this._typeIndex.delete(type);
      }
    }
    
    // Remove from context index
    const context = component.context;
    if (context && this._contextIndex.has(context)) {
      const contextSet = this._contextIndex.get(context);
      contextSet.delete(component);
      if (contextSet.size === 0) {
        this._contextIndex.delete(context);
      }
    }
    
    // Remove from tag indexes
    const tags = component.tags || [];
    if (Array.isArray(tags)) {
      for (const tag of tags) {
        if (this._tagIndex.has(tag)) {
          const tagSet = this._tagIndex.get(tag);
          tagSet.delete(component);
          if (tagSet.size === 0) {
            this._tagIndex.delete(tag);
          }
        }
      }
    }
    
    // Trigger unmount handlers for this type
    if (this._unmountHandlers.has(type)) {
      const handlers = this._unmountHandlers.get(type);
      for (const handler of handlers) {
        try {
          handler(component);
        } catch (error) {
          console.error(`Error in unmount handler for ${type}:${componentId}`, error);
        }
      }
    }
    
    // Remove from main component map
    this._components.delete(componentId);
    
    if (this._debug) {
      console.log(`ComponentRegistry: Unregistered ${type}:${componentId}`);
    }
    
    return true;
  }
  
  /**
   * Find a component by its ID
   * @param {string} id - The component ID to find
   * @returns {Object|null} - The component if found, null otherwise
   */
  findById(id) {
    return this._components.get(id) || null;
  }
  
  /**
   * Find components by type
   * @param {string} type - The component type to find
   * @returns {Array} - Array of matching components
   */
  findByType(type) {
    if (!this._typeIndex.has(type)) {
      return [];
    }
    return Array.from(this._typeIndex.get(type));
  }
  
  /**
   * Find components in a specific context
   * @param {string} contextId - The context ID to search in
   * @returns {Array} - Array of matching components
   */
  findInContext(contextId) {
    if (!this._contextIndex.has(contextId)) {
      return [];
    }
    return Array.from(this._contextIndex.get(contextId));
  }
  
  /**
   * Find components with a specific tag
   * @param {string} tag - The tag to search for
   * @returns {Array} - Array of matching components
   */
  findByTag(tag) {
    if (!this._tagIndex.has(tag)) {
      return [];
    }
    return Array.from(this._tagIndex.get(tag));
  }
  
  /**
   * Get all registered components
   * @returns {Array} - Array of all components
   */
  findAll() {
    return Array.from(this._components.values());
  }
  
  /**
   * Find components using a custom predicate function
   * @param {Function} predicateFn - Function that takes a component and returns boolean
   * @returns {Array} - Array of matching components
   */
  query(predicateFn) {
    if (typeof predicateFn !== 'function') {
      console.error('ComponentRegistry: query requires a predicate function');
      return [];
    }
    return Array.from(this._components.values()).filter(predicateFn);
  }
  
  /**
   * Register a handler to be called when components of the specified type are mounted
   * @param {string} type - The component type to watch
   * @param {Function} handler - Handler function called with the component instance
   */
  onMount(type, handler) {
    if (typeof handler !== 'function') {
      console.error('ComponentRegistry: onMount requires a handler function');
      return;
    }
    
    if (!this._mountHandlers.has(type)) {
      this._mountHandlers.set(type, []);
    }
    this._mountHandlers.get(type).push(handler);
    
    // Call handler for existing components of this type
    const existingComponents = this.findByType(type);
    for (const component of existingComponents) {
      try {
        handler(component);
      } catch (error) {
        console.error(`Error in mount handler for ${type}:${component.id}`, error);
      }
    }
  }
  
  /**
   * Register a handler to be called when components of the specified type are unmounted
   * @param {string} type - The component type to watch
   * @param {Function} handler - Handler function called with the component instance
   */
  onUnmount(type, handler) {
    if (typeof handler !== 'function') {
      console.error('ComponentRegistry: onUnmount requires a handler function');
      return;
    }
    
    if (!this._unmountHandlers.has(type)) {
      this._unmountHandlers.set(type, []);
    }
    this._unmountHandlers.get(type).push(handler);
  }
  
  /**
   * Set debug mode
   * @param {boolean} enable - Whether to enable debug mode
   */
  setDebug(enable) {
    this._debug = !!enable;
  }
  
  /**
   * Get the count of registered components
   * @returns {number} - Total component count
   */
  getCount() {
    return this._components.size;
  }
  
  /**
   * Get statistics about registered components
   * @returns {Object} - Registry statistics
   */
  getStats() {
    return {
      totalCount: this._components.size,
      typeCount: this._typeIndex.size,
      contextCount: this._contextIndex.size,
      tagCount: this._tagIndex.size,
      types: Array.from(this._typeIndex.keys()).map(type => ({
        type,
        count: this._typeIndex.get(type).size
      })),
      contexts: Array.from(this._contextIndex.keys()).map(context => ({
        context,
        count: this._contextIndex.get(context).size
      }))
    };
  }
}

// Export singleton instance
export const Registry = new ComponentRegistry();

// Default export for compatibility
export default Registry; 