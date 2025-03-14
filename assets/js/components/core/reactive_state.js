/**
 * Reactive State Management System
 * 
 * Provides a proxy-based reactive state system that tracks property access and changes,
 * allowing for automatic UI updates, computed properties, and state history.
 */

/**
 * Creates a reactive object using JavaScript Proxy
 * @param {Object} target - The object to make reactive
 * @param {Object} options - Configuration options
 * @returns {Proxy} - A reactive proxy of the target object
 */
export function reactive(target, options = {}) {
  const {
    onChange = () => {},
    onAccess = () => {},
    path = []
  } = options;

  // Don't wrap primitive values
  if (target === null || typeof target !== 'object') {
    return target;
  }
  
  return new Proxy(target, {
    get(target, property, receiver) {
      // Skip special properties like Symbol and __proto__
      if (typeof property === 'symbol' || property === '__proto__') {
        return Reflect.get(target, property, receiver);
      }
      
      const value = Reflect.get(target, property, receiver);
      const currentPath = [...path, property];
      
      // Notify access for dependency tracking
      onAccess(currentPath.join('.'), value);
      
      // Make nested objects reactive too
      if (typeof value === 'object' && value !== null) {
        return reactive(value, {
          onChange,
          onAccess,
          path: currentPath
        });
      }
      
      return value;
    },
    
    set(target, property, value, receiver) {
      // Skip special properties
      if (typeof property === 'symbol' || property === '__proto__') {
        return Reflect.set(target, property, value, receiver);
      }
      
      const currentPath = [...path, property];
      const oldValue = Reflect.get(target, property, receiver);
      
      // Only trigger change if the value actually changed
      if (oldValue !== value) {
        const result = Reflect.set(target, property, value, receiver);
        
        // Notify about the change
        onChange(currentPath.join('.'), value, oldValue);
        
        return result;
      }
      
      return Reflect.set(target, property, value, receiver);
    },
    
    deleteProperty(target, property) {
      // Skip special properties
      if (typeof property === 'symbol' || property === '__proto__') {
        return Reflect.deleteProperty(target, property);
      }
      
      const currentPath = [...path, property];
      const oldValue = Reflect.get(target, property);
      const result = Reflect.deleteProperty(target, property);
      
      // Notify about the deletion
      onChange(currentPath.join('.'), undefined, oldValue);
      
      return result;
    }
  });
}

/**
 * Main state manager class for handling reactive state
 */
export class StateManager {
  constructor(options = {}) {
    this._state = {};
    this._computedValues = new Map();
    this._dependencies = new Map();
    this._watchers = new Map();
    this._currentlyTracking = null;
    this._batchMode = false;
    this._pendingUpdates = new Set();
    this._updateCallback = options.updateCallback || (() => {});
    this._historyEnabled = options.historyEnabled || false;
    this._history = [];
    this._historyLimit = options.historyLimit || 50;
    this._currentHistoryIndex = -1;
  }
  
  /**
   * Creates a reactive state object with the provided initial state
   * @param {Object} initialState - Initial state object
   * @returns {Proxy} - Reactive state object
   */
  defineState(initialState = {}) {
    this._state = reactive(initialState, {
      onChange: this._handleStateChange.bind(this),
      onAccess: this._trackDependency.bind(this)
    });
    
    return this._state;
  }
  
  /**
   * Track dependencies for computed properties
   * @param {String} path - Property path
   * @param {*} value - Property value
   * @private
   */
  _trackDependency(path, value) {
    // If not tracking dependencies for a computed property, do nothing
    if (!this._currentlyTracking) return;
    
    // Add this path to the dependencies of the currently tracked computed property
    const deps = this._dependencies.get(this._currentlyTracking) || new Set();
    deps.add(path);
    this._dependencies.set(this._currentlyTracking, deps);
  }
  
  /**
   * Handle state changes and trigger updates
   * @param {String} path - Path to the changed property
   * @param {*} newValue - New property value
   * @param {*} oldValue - Previous property value
   * @private
   */
  _handleStateChange(path, newValue, oldValue) {
    // Record history if enabled
    if (this._historyEnabled && !this._isTimeTravel) {
      this._addToHistory(path, newValue, oldValue);
    }
    
    // Update computed properties that depend on this path
    this._updateComputedProperties(path);
    
    // Notify watchers
    this._notifyWatchers(path, newValue, oldValue);
    
    // If in batch mode, just queue the update, otherwise trigger immediately
    if (this._batchMode) {
      this._pendingUpdates.add(path);
    } else {
      this._updateCallback(path, newValue, oldValue);
    }
  }
  
  /**
   * Add state change to history
   * @param {String} path - Path to the changed property
   * @param {*} newValue - New property value
   * @param {*} oldValue - Previous property value
   * @private
   */
  _addToHistory(path, newValue, oldValue) {
    // If we're not at the end of history, truncate future history
    if (this._currentHistoryIndex < this._history.length - 1) {
      this._history = this._history.slice(0, this._currentHistoryIndex + 1);
    }
    
    // Add new history entry
    this._history.push({
      path,
      newValue: JSON.parse(JSON.stringify(newValue)), // Deep copy
      oldValue: JSON.parse(JSON.stringify(oldValue)), // Deep copy
      timestamp: Date.now()
    });
    
    // Limit history length
    if (this._history.length > this._historyLimit) {
      this._history.shift();
    }
    
    this._currentHistoryIndex = this._history.length - 1;
  }
  
  /**
   * Update computed properties that depend on a changed property
   * @param {String} changedPath - Path to the changed property
   * @private
   */
  _updateComputedProperties(changedPath) {
    for (const [computedName, deps] of this._dependencies.entries()) {
      // Check if this computed property depends on the changed path
      // or if it uses a parent object that contains the changed path
      let needsUpdate = false;
      
      for (const dep of deps) {
        if (dep === changedPath || 
            changedPath.startsWith(dep + '.') || 
            dep.startsWith(changedPath + '.')) {
          needsUpdate = true;
          break;
        }
      }
      
      if (needsUpdate) {
        this._computeValue(computedName);
      }
    }
  }
  
  /**
   * Notify watchers about state changes
   * @param {String} path - Path to the changed property
   * @param {*} newValue - New property value
   * @param {*} oldValue - Previous property value
   * @private
   */
  _notifyWatchers(path, newValue, oldValue) {
    // Call watchers that match the exact path
    const exactWatchers = this._watchers.get(path);
    if (exactWatchers) {
      for (const callback of exactWatchers) {
        callback(newValue, oldValue, path);
      }
    }
    
    // Call watchers that match parent paths
    const parts = path.split('.');
    while (parts.length > 1) {
      parts.pop();
      const parentPath = parts.join('.');
      const parentWatchers = this._watchers.get(parentPath);
      
      if (parentWatchers) {
        for (const callback of parentWatchers) {
          callback(newValue, oldValue, path);
        }
      }
    }
    
    // Call global watchers
    const globalWatchers = this._watchers.get('*');
    if (globalWatchers) {
      for (const callback of globalWatchers) {
        callback(newValue, oldValue, path);
      }
    }
  }
  
  /**
   * Compute a value for a computed property
   * @param {String} name - Computed property name
   * @private
   */
  _computeValue(name) {
    const computed = this._computedValues.get(name);
    if (!computed) return;
    
    // Clear existing dependencies
    this._dependencies.set(name, new Set());
    
    // Track dependencies during computation
    this._currentlyTracking = name;
    const value = computed.compute();
    this._currentlyTracking = null;
    
    // Store the computed value
    computed.value = value;
    
    return value;
  }
  
  /**
   * Define a computed property
   * @param {String} key - Property name
   * @param {String[]} dependencies - Array of property paths this computed property depends on
   * @param {Function} computeFn - Function that computes the property value
   * @returns {*} - The computed value
   */
  compute(key, dependencies, computeFn) {
    // Store the compute function
    this._computedValues.set(key, {
      compute: computeFn,
      value: undefined
    });
    
    // Pre-register dependencies if provided
    if (Array.isArray(dependencies)) {
      this._dependencies.set(key, new Set(dependencies));
    }
    
    // Define computed property on state
    Object.defineProperty(this._state, key, {
      get: () => {
        const computed = this._computedValues.get(key);
        
        // Initialize if not already computed
        if (computed.value === undefined) {
          this._computeValue(key);
        }
        
        return computed.value;
      },
      enumerable: true,
      configurable: true
    });
    
    // Do initial computation
    const initialValue = this._computeValue(key);
    
    return initialValue;
  }
  
  /**
   * Watch for changes to a specific state path
   * @param {String|String[]} path - Property path or array of paths to watch
   * @param {Function} callback - Function to call when value changes
   * @returns {Function} - Function to remove the watcher
   */
  watch(path, callback) {
    const paths = Array.isArray(path) ? path : [path];
    
    for (const p of paths) {
      if (!this._watchers.has(p)) {
        this._watchers.set(p, new Set());
      }
      
      this._watchers.get(p).add(callback);
    }
    
    // Return function to remove the watcher
    return () => {
      for (const p of paths) {
        const watchers = this._watchers.get(p);
        if (watchers) {
          watchers.delete(callback);
          if (watchers.size === 0) {
            this._watchers.delete(p);
          }
        }
      }
    };
  }
  
  /**
   * Batch multiple state changes into a single update
   * @param {Function} callback - Function that makes state changes
   */
  batch(callback) {
    const wasBatchMode = this._batchMode;
    this._batchMode = true;
    
    try {
      callback();
    } finally {
      // Only trigger updates if this was the outermost batch call
      if (!wasBatchMode) {
        this._batchMode = false;
        
        // Process all pending updates
        if (this._pendingUpdates.size > 0) {
          const updates = Array.from(this._pendingUpdates);
          this._pendingUpdates.clear();
          
          // Call update callback once with all paths
          this._updateCallback(updates);
        }
      }
    }
  }
  
  /**
   * Perform a transaction that can be rolled back
   * @param {Function} callback - Function that returns true for commit, false for rollback
   * @returns {Boolean} - Whether the transaction was committed
   */
  transaction(callback) {
    // Save current state for potential rollback
    const snapshot = JSON.parse(JSON.stringify(this._state));
    
    // Execute transaction in batch mode
    let result = false;
    this.batch(() => {
      result = callback();
    });
    
    // Rollback if needed
    if (!result) {
      // Disable history during rollback
      const historyEnabled = this._historyEnabled;
      this._historyEnabled = false;
      
      // Apply the snapshot back to state
      this.batch(() => {
        // Clear current state
        for (const key in this._state) {
          delete this._state[key];
        }
        
        // Restore from snapshot
        Object.assign(this._state, snapshot);
      });
      
      // Restore history setting
      this._historyEnabled = historyEnabled;
    }
    
    return result;
  }
  
  /**
   * Get the history of state changes
   * @returns {Array} - History entries
   */
  getHistory() {
    return this._history.slice();
  }
  
  /**
   * Clear the state change history
   */
  clearHistory() {
    this._history = [];
    this._currentHistoryIndex = -1;
  }
  
  /**
   * Revert state to a previous point in history
   * @param {Number} steps - Number of steps to go back (positive) or forward (negative)
   * @returns {Boolean} - Whether the revert was successful
   */
  revert(steps) {
    if (steps === 0 || this._history.length === 0) return false;
    
    const targetIndex = this._currentHistoryIndex - steps;
    if (targetIndex < -1 || targetIndex >= this._history.length) return false;
    
    this._isTimeTravel = true;
    
    try {
      if (steps > 0) {
        // Going backward in time
        for (let i = 0; i < steps; i++) {
          const entry = this._history[this._currentHistoryIndex];
          
          // Apply the old value
          const pathParts = entry.path.split('.');
          let current = this._state;
          
          // Navigate to the parent object
          for (let j = 0; j < pathParts.length - 1; j++) {
            current = current[pathParts[j]];
          }
          
          // Set the old value
          current[pathParts[pathParts.length - 1]] = entry.oldValue;
          
          this._currentHistoryIndex--;
        }
      } else {
        // Going forward in time
        for (let i = 0; i < -steps; i++) {
          this._currentHistoryIndex++;
          const entry = this._history[this._currentHistoryIndex];
          
          // Apply the new value
          const pathParts = entry.path.split('.');
          let current = this._state;
          
          // Navigate to the parent object
          for (let j = 0; j < pathParts.length - 1; j++) {
            current = current[pathParts[j]];
          }
          
          // Set the new value
          current[pathParts[pathParts.length - 1]] = entry.newValue;
        }
      }
    } finally {
      this._isTimeTravel = false;
    }
    
    // Trigger update for all computed properties
    for (const computedName of this._computedValues.keys()) {
      this._computeValue(computedName);
    }
    
    // Trigger a global update
    this._updateCallback('*');
    
    return true;
  }
}

// Default export for convenience
export default StateManager; 