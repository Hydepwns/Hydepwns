/**
 * Performance Monitor
 * 
 * Tracks performance metrics for components including render time,
 * update frequency, and event handling time.
 */

import ComponentRegistry from '../core/component_registry';

class PerformanceMonitor {
  constructor() {
    this._metrics = new Map();
    this._monitoredComponents = new Set();
    this._isRecording = false;
    this._defaultOptions = {
      trackRenderTime: true,
      trackEventHandlingTime: true,
      trackUpdateFrequency: true,
      trackMemoryUsage: false,
      sampleSize: 10,
      warningThresholds: {
        renderTime: 16, // ms (60fps)
        eventHandlingTime: 50, // ms
        updateFrequency: 5, // updates per second
      }
    };
    
    // Original methods that we patch for monitoring
    this._originalMethods = new WeakMap();
    
    // For timing calculations
    this._lastUpdateTimes = new Map();
    this._updateCounts = new Map();
    this._updateCounterInterval = null;
    
    // Bind methods that will be used as callbacks
    this._resetUpdateCounters = this._resetUpdateCounters.bind(this);
  }
  
  /**
   * Start monitoring a component's performance
   * @param {String} componentId - ID of the component to monitor
   * @param {Object} options - Monitoring options
   */
  monitorComponent(componentId, options = {}) {
    const registry = ComponentRegistry.getInstance();
    const component = registry.getById(componentId);
    
    if (!component) {
      console.warn(`Component with ID ${componentId} not found.`);
      return;
    }
    
    // Merge with default options
    const monitorOptions = { ...this._defaultOptions, ...options };
    
    // Initialize metrics for this component
    this._metrics.set(componentId, {
      renderTimes: [],
      eventHandlingTimes: new Map(), // Map of event name -> times
      updateFrequency: 0,
      lastWarnings: [],
      options: monitorOptions
    });
    
    // Start tracking performance
    this._patchComponentMethods(component, componentId);
    
    // Add to monitored components
    this._monitoredComponents.add(componentId);
    
    // Start update frequency tracking if not already running
    this._startUpdateFrequencyTracking();
    
    return true;
  }
  
  /**
   * Stop monitoring a component
   * @param {String} componentId - ID of the component to stop monitoring
   */
  stopMonitoring(componentId) {
    const registry = ComponentRegistry.getInstance();
    const component = registry.getById(componentId);
    
    if (component) {
      this._unpatchComponentMethods(component);
    }
    
    this._monitoredComponents.delete(componentId);
    
    // Stop update frequency tracking if no components are being monitored
    if (this._monitoredComponents.size === 0) {
      this._stopUpdateFrequencyTracking();
    }
    
    return this._metrics.delete(componentId);
  }
  
  /**
   * Start monitoring all components
   * @param {Object} options - Monitoring options
   */
  monitorAllComponents(options = {}) {
    const registry = ComponentRegistry.getInstance();
    const components = registry.getAll();
    
    components.forEach(component => {
      this.monitorComponent(component.id, options);
    });
    
    // Also register for future components
    registry.onRegister((component) => {
      if (this._isRecording) {
        this.monitorComponent(component.id, options);
      }
    });
    
    this._isRecording = true;
  }
  
  /**
   * Stop monitoring all components
   */
  stopMonitoringAll() {
    const componentIds = [...this._monitoredComponents];
    
    componentIds.forEach(id => {
      this.stopMonitoring(id);
    });
    
    this._isRecording = false;
  }
  
  /**
   * Get performance metrics for a specific component or all components
   * @param {String} componentId - Optional component ID, if not provided returns all metrics
   * @param {Boolean} formatted - Whether to return formatted metrics for display
   * @returns {Object} - Performance metrics
   */
  getMetrics(componentId, formatted = false) {
    if (componentId) {
      const metrics = this._metrics.get(componentId);
      return formatted ? this._formatMetrics(componentId, metrics) : metrics;
    }
    
    // Return all metrics
    const result = {};
    this._metrics.forEach((metrics, id) => {
      result[id] = formatted ? this._formatMetrics(id, metrics) : metrics;
    });
    
    return result;
  }
  
  /**
   * Clear collected metrics
   * @param {String} componentId - Optional component ID, if not provided clears all metrics
   */
  clearMetrics(componentId) {
    if (componentId) {
      const metrics = this._metrics.get(componentId);
      if (metrics) {
        metrics.renderTimes = [];
        metrics.eventHandlingTimes = new Map();
        metrics.updateFrequency = 0;
        metrics.lastWarnings = [];
      }
    } else {
      // Clear all metrics but keep monitoring
      this._metrics.forEach((metrics) => {
        metrics.renderTimes = [];
        metrics.eventHandlingTimes = new Map();
        metrics.updateFrequency = 0;
        metrics.lastWarnings = [];
      });
    }
  }
  
  /**
   * Patch component methods to measure performance
   * @param {Object} component - Component instance
   * @param {String} componentId - Component ID
   * @private
   */
  _patchComponentMethods(component, componentId) {
    if (!component) return;
    
    const metrics = this._metrics.get(componentId);
    if (!metrics) return;
    
    // Store original methods for later restoration
    const originals = {};
    
    // Patch render method if it exists
    if (component.render && metrics.options.trackRenderTime) {
      originals.render = component.render;
      
      component.render = (...args) => {
        const start = performance.now();
        const result = originals.render.apply(component, args);
        const end = performance.now();
        
        this._recordRenderTime(componentId, end - start);
        
        // Record this update for frequency tracking
        this._recordUpdate(componentId);
        
        return result;
      };
    }
    
    // Patch event handlers
    if (metrics.options.trackEventHandlingTime) {
      // Find event handlers (methods starting with 'handle' or 'on')
      Object.getOwnPropertyNames(Object.getPrototypeOf(component)).forEach(method => {
        if ((method.startsWith('handle') || method.startsWith('on')) && 
            typeof component[method] === 'function' && 
            method !== 'handleEvent') { // Skip standard handleEvent
          
          originals[method] = component[method];
          
          component[method] = (...args) => {
            const start = performance.now();
            const result = originals[method].apply(component, args);
            const end = performance.now();
            
            this._recordEventHandlingTime(componentId, method, end - start);
            
            return result;
          };
        }
      });
    }
    
    // Store originals for later restoration
    this._originalMethods.set(component, originals);
  }
  
  /**
   * Restore original component methods
   * @param {Object} component - Component instance
   * @private
   */
  _unpatchComponentMethods(component) {
    if (!component) return;
    
    const originals = this._originalMethods.get(component);
    if (!originals) return;
    
    // Restore original methods
    Object.keys(originals).forEach(method => {
      component[method] = originals[method];
    });
    
    // Clear stored originals
    this._originalMethods.delete(component);
  }
  
  /**
   * Record a render time
   * @param {String} componentId - Component ID
   * @param {Number} time - Render time in ms
   * @private
   */
  _recordRenderTime(componentId, time) {
    const metrics = this._metrics.get(componentId);
    if (!metrics) return;
    
    // Add to render times
    metrics.renderTimes.push(time);
    
    // Keep only the latest samples
    if (metrics.renderTimes.length > metrics.options.sampleSize) {
      metrics.renderTimes.shift();
    }
    
    // Check if render time exceeds warning threshold
    if (time > metrics.options.warningThresholds.renderTime) {
      this._recordWarning(componentId, 'renderTime', 
        `Slow render time: ${time.toFixed(2)}ms (threshold: ${metrics.options.warningThresholds.renderTime}ms)`);
    }
  }
  
  /**
   * Record an event handling time
   * @param {String} componentId - Component ID
   * @param {String} eventName - Event handler name
   * @param {Number} time - Handling time in ms
   * @private
   */
  _recordEventHandlingTime(componentId, eventName, time) {
    const metrics = this._metrics.get(componentId);
    if (!metrics) return;
    
    // Get times for this event, or create new array
    if (!metrics.eventHandlingTimes.has(eventName)) {
      metrics.eventHandlingTimes.set(eventName, []);
    }
    
    const times = metrics.eventHandlingTimes.get(eventName);
    
    // Add to event handling times
    times.push(time);
    
    // Keep only the latest samples
    if (times.length > metrics.options.sampleSize) {
      times.shift();
    }
    
    // Check if event handling time exceeds warning threshold
    if (time > metrics.options.warningThresholds.eventHandlingTime) {
      this._recordWarning(componentId, 'eventHandlingTime', 
        `Slow event handler (${eventName}): ${time.toFixed(2)}ms (threshold: ${metrics.options.warningThresholds.eventHandlingTime}ms)`);
    }
  }
  
  /**
   * Record a component update for frequency tracking
   * @param {String} componentId - Component ID
   * @private
   */
  _recordUpdate(componentId) {
    // Update last update time
    this._lastUpdateTimes.set(componentId, Date.now());
    
    // Increment update counter
    const count = this._updateCounts.get(componentId) || 0;
    this._updateCounts.set(componentId, count + 1);
  }
  
  /**
   * Start tracking update frequency
   * @private
   */
  _startUpdateFrequencyTracking() {
    if (this._updateCounterInterval) return;
    
    // Reset counters every second to calculate updates per second
    this._updateCounterInterval = setInterval(this._resetUpdateCounters, 1000);
  }
  
  /**
   * Stop tracking update frequency
   * @private
   */
  _stopUpdateFrequencyTracking() {
    if (this._updateCounterInterval) {
      clearInterval(this._updateCounterInterval);
      this._updateCounterInterval = null;
    }
  }
  
  /**
   * Reset update counters and calculate update frequency
   * @private
   */
  _resetUpdateCounters() {
    this._monitoredComponents.forEach(componentId => {
      const updateCount = this._updateCounts.get(componentId) || 0;
      const metrics = this._metrics.get(componentId);
      
      if (metrics) {
        metrics.updateFrequency = updateCount;
        
        // Check if update frequency exceeds warning threshold
        if (updateCount > metrics.options.warningThresholds.updateFrequency) {
          this._recordWarning(componentId, 'updateFrequency', 
            `High update frequency: ${updateCount} updates/sec (threshold: ${metrics.options.warningThresholds.updateFrequency} updates/sec)`);
        }
      }
      
      // Reset counter
      this._updateCounts.set(componentId, 0);
    });
  }
  
  /**
   * Record a performance warning
   * @param {String} componentId - Component ID
   * @param {String} type - Warning type
   * @param {String} message - Warning message
   * @private
   */
  _recordWarning(componentId, type, message) {
    const metrics = this._metrics.get(componentId);
    if (!metrics) return;
    
    // Add warning
    metrics.lastWarnings.push({
      type,
      message,
      timestamp: Date.now()
    });
    
    // Keep only the latest warnings
    if (metrics.lastWarnings.length > 10) {
      metrics.lastWarnings.shift();
    }
    
    // Log to console in development
    if (process.env.NODE_ENV === 'development') {
      console.warn(`[Performance Monitor] ${message} (Component: ${componentId})`);
    }
  }
  
  /**
   * Format metrics for display
   * @param {String} componentId - Component ID
   * @param {Object} metrics - Raw metrics
   * @returns {Object} - Formatted metrics
   * @private
   */
  _formatMetrics(componentId, metrics) {
    if (!metrics) return null;
    
    const registry = ComponentRegistry.getInstance();
    const component = registry.getById(componentId);
    const componentName = component ? (component.name || 'Unnamed Component') : 'Unknown Component';
    
    // Calculate averages
    const avgRenderTime = this._calculateAverage(metrics.renderTimes);
    
    const eventMetrics = {};
    metrics.eventHandlingTimes.forEach((times, eventName) => {
      eventMetrics[eventName] = {
        avg: this._calculateAverage(times),
        min: Math.min(...times),
        max: Math.max(...times),
        samples: times.length
      };
    });
    
    return {
      componentId,
      componentName,
      render: {
        avg: avgRenderTime,
        min: metrics.renderTimes.length ? Math.min(...metrics.renderTimes) : 0,
        max: metrics.renderTimes.length ? Math.max(...metrics.renderTimes) : 0,
        samples: metrics.renderTimes.length
      },
      events: eventMetrics,
      updateFrequency: metrics.updateFrequency,
      warnings: metrics.lastWarnings,
      lastUpdate: this._lastUpdateTimes.get(componentId) || 0
    };
  }
  
  /**
   * Calculate average of an array of numbers
   * @param {Number[]} values - Array of numbers
   * @returns {Number} - Average value
   * @private
   */
  _calculateAverage(values) {
    if (!values || values.length === 0) return 0;
    const sum = values.reduce((a, b) => a + b, 0);
    return sum / values.length;
  }
}

// Singleton instance
let instance = null;

export default {
  getInstance() {
    if (!instance) {
      instance = new PerformanceMonitor();
    }
    return instance;
  }
}; 