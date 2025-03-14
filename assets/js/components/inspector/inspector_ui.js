/**
 * Component Inspector UI
 * 
 * Provides a UI overlay for inspecting components, their state, props, and relationships.
 * Only active in development mode and can be toggled on/off.
 */

import ComponentRegistry from '../core/component_registry';

class InspectorUI {
  constructor(options = {}) {
    this._isEnabled = false;
    this._options = {
      position: 'bottom-right',
      width: '350px',
      height: '500px',
      theme: 'dark',
      ...options
    };
    
    this._container = null;
    this._shadowRoot = null;
    this._activeTab = 'components';
    this._selectedComponentId = null;
    
    // Bind methods
    this._handleKeyboardShortcuts = this._handleKeyboardShortcuts.bind(this);
    this._handleComponentHover = this._handleComponentHover.bind(this);
    this._handleComponentSelection = this._handleComponentSelection.bind(this);
  }
  
  /**
   * Enable the component inspector UI
   * @param {Object} options - Override options for the inspector
   */
  enable(options = {}) {
    if (this._isEnabled) return;
    
    // Update options
    this._options = { ...this._options, ...options };
    
    // Only enable in development mode
    if (process.env.NODE_ENV !== 'development' && !this._options.forceEnable) {
      console.warn('Component Inspector is only available in development mode');
      return;
    }
    
    this._createUI();
    this._registerEventListeners();
    
    this._isEnabled = true;
    
    console.info('Component Inspector enabled. Press Ctrl+Shift+I to toggle visibility.');
  }
  
  /**
   * Disable the component inspector UI
   */
  disable() {
    if (!this._isEnabled) return;
    
    this._unregisterEventListeners();
    this._removeUI();
    
    this._isEnabled = false;
  }
  
  /**
   * Toggle inspector visibility
   */
  toggle() {
    if (!this._container) return;
    
    if (this._container.style.display === 'none') {
      this._container.style.display = 'flex';
    } else {
      this._container.style.display = 'none';
    }
  }
  
  /**
   * Create the inspector UI
   * @private
   */
  _createUI() {
    // Create container
    this._container = document.createElement('div');
    this._container.id = 'hyde-component-inspector';
    this._container.style.cssText = `
      position: fixed;
      ${this._getPositionStyles()}
      z-index: 10000;
      width: ${this._options.width};
      height: ${this._options.height};
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
      border-radius: 6px;
      overflow: hidden;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      font-size: 14px;
      display: flex;
      flex-direction: column;
    `;
    
    // Use Shadow DOM for style isolation
    this._shadowRoot = this._container.attachShadow({ mode: 'open' });
    
    // Add styles
    const styles = document.createElement('style');
    styles.textContent = this._getStyles();
    this._shadowRoot.appendChild(styles);
    
    // Create main structure
    const wrapper = document.createElement('div');
    wrapper.className = 'inspector-wrapper';
    
    // Create header
    const header = document.createElement('div');
    header.className = 'inspector-header';
    header.innerHTML = `
      <h1>Hyde Component Inspector</h1>
      <div class="inspector-controls">
        <button class="inspector-refresh-btn" title="Refresh">⟳</button>
        <button class="inspector-close-btn" title="Close">×</button>
      </div>
    `;
    
    // Create tabs
    const tabs = document.createElement('div');
    tabs.className = 'inspector-tabs';
    tabs.innerHTML = `
      <button class="inspector-tab-btn active" data-tab="components">Components</button>
      <button class="inspector-tab-btn" data-tab="events">Events</button>
      <button class="inspector-tab-btn" data-tab="performance">Performance</button>
      <button class="inspector-tab-btn" data-tab="state">State</button>
    `;
    
    // Create content area
    const content = document.createElement('div');
    content.className = 'inspector-content';
    
    // Create component tree panel
    const componentsPanel = document.createElement('div');
    componentsPanel.className = 'inspector-panel active';
    componentsPanel.dataset.panel = 'components';
    componentsPanel.innerHTML = `
      <div class="component-tree-container">
        <div class="component-tree"></div>
      </div>
      <div class="component-details">
        <h2>Select a component</h2>
        <p>Click on a component in the tree to see its details.</p>
      </div>
    `;
    
    // Create events panel
    const eventsPanel = document.createElement('div');
    eventsPanel.className = 'inspector-panel';
    eventsPanel.dataset.panel = 'events';
    eventsPanel.innerHTML = `
      <h2>Event Monitor</h2>
      <div class="event-flow-container">
        <p>No events captured yet.</p>
      </div>
    `;
    
    // Create performance panel
    const performancePanel = document.createElement('div');
    performancePanel.className = 'inspector-panel';
    performancePanel.dataset.panel = 'performance';
    performancePanel.innerHTML = `
      <h2>Performance Monitor</h2>
      <div class="performance-metrics">
        <p>No performance data available.</p>
      </div>
    `;
    
    // Create state panel
    const statePanel = document.createElement('div');
    statePanel.className = 'inspector-panel';
    statePanel.dataset.panel = 'state';
    statePanel.innerHTML = `
      <h2>State History</h2>
      <div class="state-history-container">
        <p>No state changes recorded.</p>
      </div>
    `;
    
    // Add content panels
    content.appendChild(componentsPanel);
    content.appendChild(eventsPanel);
    content.appendChild(performancePanel);
    content.appendChild(statePanel);
    
    // Assemble UI
    wrapper.appendChild(header);
    wrapper.appendChild(tabs);
    wrapper.appendChild(content);
    this._shadowRoot.appendChild(wrapper);
    
    // Add to document
    document.body.appendChild(this._container);
    
    // Add event listeners for UI controls
    this._addUIEventListeners();
    
    // Initial render of component tree
    this._renderComponentTree();
  }
  
  /**
   * Remove the inspector UI
   * @private
   */
  _removeUI() {
    if (this._container) {
      document.body.removeChild(this._container);
      this._container = null;
      this._shadowRoot = null;
    }
  }
  
  /**
   * Get positioning styles based on options
   * @returns {String} CSS position styles
   * @private
   */
  _getPositionStyles() {
    switch (this._options.position) {
      case 'top-right':
        return 'top: 20px; right: 20px;';
      case 'top-left':
        return 'top: 20px; left: 20px;';
      case 'bottom-left':
        return 'bottom: 20px; left: 20px;';
      case 'bottom-right':
      default:
        return 'bottom: 20px; right: 20px;';
    }
  }
  
  /**
   * Get inspector UI styles
   * @returns {String} CSS styles
   * @private
   */
  _getStyles() {
    return `
      :host {
        --inspector-bg: ${this._options.theme === 'dark' ? '#242424' : '#ffffff'};
        --inspector-text: ${this._options.theme === 'dark' ? '#e0e0e0' : '#333333'};
        --inspector-border: ${this._options.theme === 'dark' ? '#444444' : '#e0e0e0'};
        --inspector-highlight: ${this._options.theme === 'dark' ? '#3a71c8' : '#0073e6'};
        --inspector-highlight-bg: ${this._options.theme === 'dark' ? '#2a2a2a' : '#f0f0f0'};
        --inspector-highlight-hover: ${this._options.theme === 'dark' ? '#305aa6' : '#e5f2ff'};
        --inspector-header-bg: ${this._options.theme === 'dark' ? '#1e1e1e' : '#f5f5f5'};
      }
      
      .inspector-wrapper {
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        background-color: var(--inspector-bg);
        color: var(--inspector-text);
        border-radius: 6px;
        overflow: hidden;
      }
      
      .inspector-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 8px 12px;
        background-color: var(--inspector-header-bg);
        border-bottom: 1px solid var(--inspector-border);
      }
      
      .inspector-header h1 {
        margin: 0;
        font-size: 16px;
        font-weight: 600;
      }
      
      .inspector-controls {
        display: flex;
      }
      
      .inspector-controls button {
        background: none;
        border: none;
        color: var(--inspector-text);
        font-size: 16px;
        cursor: pointer;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 3px;
        margin-left: 4px;
      }
      
      .inspector-controls button:hover {
        background-color: var(--inspector-highlight-bg);
      }
      
      .inspector-tabs {
        display: flex;
        border-bottom: 1px solid var(--inspector-border);
      }
      
      .inspector-tab-btn {
        flex: 1;
        padding: 8px 12px;
        background: none;
        border: none;
        color: var(--inspector-text);
        cursor: pointer;
        font-size: 13px;
        border-bottom: 2px solid transparent;
      }
      
      .inspector-tab-btn:hover {
        background-color: var(--inspector-highlight-bg);
      }
      
      .inspector-tab-btn.active {
        border-bottom: 2px solid var(--inspector-highlight);
        font-weight: 600;
      }
      
      .inspector-content {
        flex: 1;
        overflow: hidden;
        position: relative;
      }
      
      .inspector-panel {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        display: none;
        padding: 12px;
        box-sizing: border-box;
      }
      
      .inspector-panel.active {
        display: block;
      }
      
      .inspector-panel h2 {
        margin: 0 0 12px 0;
        font-size: 14px;
        font-weight: 600;
      }
      
      .component-tree-container {
        border: 1px solid var(--inspector-border);
        border-radius: 4px;
        margin-bottom: 12px;
        max-height: 200px;
        overflow: auto;
      }
      
      .component-tree {
        padding: 8px;
        font-size: 13px;
      }
      
      .component-tree-item {
        padding: 4px 0;
        cursor: pointer;
        white-space: nowrap;
      }
      
      .component-tree-item:hover {
        background-color: var(--inspector-highlight-hover);
      }
      
      .component-tree-item.selected {
        background-color: var(--inspector-highlight-bg);
        font-weight: 600;
      }
      
      .component-tree-item-indent {
        display: inline-block;
        width: 16px;
      }
      
      .component-details {
        border: 1px solid var(--inspector-border);
        border-radius: 4px;
        padding: 8px;
      }
      
      .component-property {
        margin-bottom: 8px;
      }
      
      .component-property-name {
        font-weight: 600;
        margin-bottom: 4px;
      }
      
      .component-property-value {
        font-family: monospace;
        white-space: pre-wrap;
        word-break: break-all;
        background-color: var(--inspector-highlight-bg);
        padding: 4px;
        border-radius: 3px;
        font-size: 12px;
        max-height: 200px;
        overflow: auto;
      }
      
      .event-flow-container,
      .performance-metrics,
      .state-history-container {
        border: 1px solid var(--inspector-border);
        border-radius: 4px;
        padding: 8px;
        height: calc(100% - 50px);
        overflow: auto;
      }
    `;
  }
  
  /**
   * Add event listeners for UI controls
   * @private
   */
  _addUIEventListeners() {
    if (!this._shadowRoot) return;
    
    // Tab buttons
    const tabButtons = this._shadowRoot.querySelectorAll('.inspector-tab-btn');
    tabButtons.forEach(button => {
      button.addEventListener('click', () => {
        // Update active tab
        this._activeTab = button.dataset.tab;
        
        // Update UI
        tabButtons.forEach(b => b.classList.remove('active'));
        button.classList.add('active');
        
        // Show active panel
        const panels = this._shadowRoot.querySelectorAll('.inspector-panel');
        panels.forEach(panel => {
          panel.classList.toggle('active', panel.dataset.panel === this._activeTab);
        });
      });
    });
    
    // Close button
    const closeButton = this._shadowRoot.querySelector('.inspector-close-btn');
    if (closeButton) {
      closeButton.addEventListener('click', () => {
        this.toggle();
      });
    }
    
    // Refresh button
    const refreshButton = this._shadowRoot.querySelector('.inspector-refresh-btn');
    if (refreshButton) {
      refreshButton.addEventListener('click', () => {
        this._renderComponentTree();
        this._updatePanels();
      });
    }
  }
  
  /**
   * Register global event listeners
   * @private
   */
  _registerEventListeners() {
    // Keyboard shortcuts
    document.addEventListener('keydown', this._handleKeyboardShortcuts);
    
    // Component hovering - highlight components when inspector is open
    document.addEventListener('mouseover', this._handleComponentHover);
    document.addEventListener('click', this._handleComponentSelection, true);
  }
  
  /**
   * Unregister global event listeners
   * @private
   */
  _unregisterEventListeners() {
    document.removeEventListener('keydown', this._handleKeyboardShortcuts);
    document.removeEventListener('mouseover', this._handleComponentHover);
    document.removeEventListener('click', this._handleComponentSelection, true);
  }
  
  /**
   * Handle keyboard shortcuts
   * @param {KeyboardEvent} event - Keyboard event
   * @private
   */
  _handleKeyboardShortcuts(event) {
    // Ctrl+Shift+I to toggle inspector
    if (event.ctrlKey && event.shiftKey && event.key === 'I') {
      event.preventDefault();
      this.toggle();
    }
  }
  
  /**
   * Handle component hover
   * @param {MouseEvent} event - Mouse event
   * @private
   */
  _handleComponentHover(event) {
    if (!this._isEnabled || this._container.style.display === 'none') return;
    
    // Remove any existing highlights
    document.querySelectorAll('.hyde-component-highlight').forEach(el => {
      el.remove();
    });
    
    // Find component element
    const componentEl = this._findComponentElement(event.target);
    if (!componentEl) return;
    
    // Create highlight
    this._highlightComponent(componentEl);
  }
  
  /**
   * Handle component selection
   * @param {MouseEvent} event - Mouse event
   * @private
   */
  _handleComponentSelection(event) {
    if (!this._isEnabled || this._container.style.display === 'none') return;
    
    // Check if we clicked on the inspector itself
    if (this._container.contains(event.target) || event.target === this._container) {
      return;
    }
    
    // Find component element
    const componentEl = this._findComponentElement(event.target);
    if (!componentEl) return;
    
    // Prevent default action to avoid triggering component behavior
    event.preventDefault();
    event.stopPropagation();
    
    // Select component
    const componentId = componentEl.dataset.componentId;
    if (componentId) {
      this._selectComponent(componentId);
    }
  }
  
  /**
   * Find component element containing the target
   * @param {HTMLElement} target - Target element
   * @returns {HTMLElement|null} - Component element or null
   * @private
   */
  _findComponentElement(target) {
    let element = target;
    
    // Traverse up the DOM tree to find component element
    while (element && element !== document.body) {
      if (element.dataset && element.dataset.componentId) {
        return element;
      }
      element = element.parentElement;
    }
    
    return null;
  }
  
  /**
   * Highlight a component element
   * @param {HTMLElement} element - Component element
   * @private
   */
  _highlightComponent(element) {
    const rect = element.getBoundingClientRect();
    
    const highlight = document.createElement('div');
    highlight.className = 'hyde-component-highlight';
    highlight.style.cssText = `
      position: absolute;
      top: ${rect.top + window.scrollY}px;
      left: ${rect.left + window.scrollX}px;
      width: ${rect.width}px;
      height: ${rect.height}px;
      border: 2px solid #0073e6;
      background-color: rgba(0, 115, 230, 0.1);
      z-index: 9999;
      pointer-events: none;
    `;
    
    document.body.appendChild(highlight);
  }
  
  /**
   * Select a component
   * @param {String} componentId - Component ID
   * @private
   */
  _selectComponent(componentId) {
    this._selectedComponentId = componentId;
    
    // Update UI
    this._renderComponentTree();
    this._renderComponentDetails(componentId);
    
    // Switch to components tab if not already active
    if (this._activeTab !== 'components') {
      const tabButton = this._shadowRoot.querySelector('.inspector-tab-btn[data-tab="components"]');
      if (tabButton) {
        tabButton.click();
      }
    }
  }
  
  /**
   * Render the component tree
   * @private
   */
  _renderComponentTree() {
    if (!this._shadowRoot) return;
    
    const treeContainer = this._shadowRoot.querySelector('.component-tree');
    if (!treeContainer) return;
    
    // Get component tree from registry
    const registry = ComponentRegistry.getInstance();
    const components = registry.getAll();
    
    if (components.length === 0) {
      treeContainer.innerHTML = '<p>No components registered.</p>';
      return;
    }
    
    // Build tree structure
    const tree = this._buildComponentTree(components);
    
    // Render tree
    treeContainer.innerHTML = '';
    this._renderTreeNode(treeContainer, tree, 0);
  }
  
  /**
   * Build component tree structure
   * @param {Array} components - List of components
   * @returns {Array} - Tree structure
   * @private
   */
  _buildComponentTree(components) {
    // Map components by ID
    const componentsById = {};
    components.forEach(component => {
      componentsById[component.id] = { ...component, children: [] };
    });
    
    // Build tree
    const rootNodes = [];
    
    components.forEach(component => {
      const node = componentsById[component.id];
      
      if (component.parentId && componentsById[component.parentId]) {
        // Add as child to parent
        componentsById[component.parentId].children.push(node);
      } else {
        // Add as root node
        rootNodes.push(node);
      }
    });
    
    return rootNodes;
  }
  
  /**
   * Render a tree node
   * @param {HTMLElement} container - Container element
   * @param {Array} nodes - Tree nodes
   * @param {Number} level - Indentation level
   * @private
   */
  _renderTreeNode(container, nodes, level) {
    nodes.forEach(node => {
      const item = document.createElement('div');
      item.className = 'component-tree-item';
      if (node.id === this._selectedComponentId) {
        item.classList.add('selected');
      }
      
      // Indentation
      for (let i = 0; i < level; i++) {
        const indent = document.createElement('span');
        indent.className = 'component-tree-item-indent';
        item.appendChild(indent);
      }
      
      // Component name
      item.appendChild(document.createTextNode(`${node.name || 'Component'} (${node.id})`));
      
      // Click handler
      item.addEventListener('click', event => {
        event.stopPropagation();
        this._selectComponent(node.id);
      });
      
      container.appendChild(item);
      
      // Render children
      if (node.children && node.children.length > 0) {
        this._renderTreeNode(container, node.children, level + 1);
      }
    });
  }
  
  /**
   * Render component details
   * @param {String} componentId - Component ID
   * @private
   */
  _renderComponentDetails(componentId) {
    if (!this._shadowRoot) return;
    
    const detailsContainer = this._shadowRoot.querySelector('.component-details');
    if (!detailsContainer) return;
    
    // Get component from registry
    const registry = ComponentRegistry.getInstance();
    const component = registry.getById(componentId);
    
    if (!component) {
      detailsContainer.innerHTML = '<p>Component not found.</p>';
      return;
    }
    
    // Render component details
    let html = `<h2>${component.name || 'Component'}</h2>`;
    
    // Basic info
    html += `
      <div class="component-property">
        <div class="component-property-name">ID</div>
        <div class="component-property-value">${component.id}</div>
      </div>
    `;
    
    if (component.element) {
      html += `
        <div class="component-property">
          <div class="component-property-name">Element</div>
          <div class="component-property-value">${component.element.tagName.toLowerCase()}</div>
        </div>
      `;
    }
    
    // State
    if (component.state) {
      html += `
        <div class="component-property">
          <div class="component-property-name">State</div>
          <div class="component-property-value">${this._formatValue(component.state)}</div>
        </div>
      `;
    }
    
    // Props
    if (component.props) {
      html += `
        <div class="component-property">
          <div class="component-property-name">Props</div>
          <div class="component-property-value">${this._formatValue(component.props)}</div>
        </div>
      `;
    }
    
    // Methods
    const methods = this._getComponentMethods(component);
    if (methods.length > 0) {
      html += `
        <div class="component-property">
          <div class="component-property-name">Methods</div>
          <div class="component-property-value">${methods.join(', ')}</div>
        </div>
      `;
    }
    
    detailsContainer.innerHTML = html;
  }
  
  /**
   * Format a value for display
   * @param {*} value - Value to format
   * @returns {String} - Formatted value
   * @private
   */
  _formatValue(value) {
    try {
      return JSON.stringify(value, null, 2);
    } catch (error) {
      return String(value);
    }
  }
  
  /**
   * Get component methods
   * @param {Object} component - Component object
   * @returns {Array} - List of method names
   * @private
   */
  _getComponentMethods(component) {
    const methods = [];
    
    // Get all properties of the component
    for (const prop in component) {
      // Check if it's a function and not a private method
      if (typeof component[prop] === 'function' && !prop.startsWith('_')) {
        methods.push(prop);
      }
    }
    
    return methods;
  }
  
  /**
   * Update all panels with fresh data
   * @private
   */
  _updatePanels() {
    // Update based on active tab
    switch (this._activeTab) {
      case 'components':
        if (this._selectedComponentId) {
          this._renderComponentDetails(this._selectedComponentId);
        }
        break;
      case 'events':
        this._updateEventPanel();
        break;
      case 'performance':
        this._updatePerformancePanel();
        break;
      case 'state':
        this._updateStatePanel();
        break;
    }
  }
  
  /**
   * Update the event panel
   * @private
   */
  _updateEventPanel() {
    // This will be implemented in integration with the EventMonitor
  }
  
  /**
   * Update the performance panel
   * @private
   */
  _updatePerformancePanel() {
    // This will be implemented in integration with the PerformanceMonitor
  }
  
  /**
   * Update the state panel
   * @private
   */
  _updateStatePanel() {
    // This will be implemented in integration with state history
  }
}

// Singleton instance
let instance = null;

export default {
  getInstance() {
    if (!instance) {
      instance = new InspectorUI();
    }
    return instance;
  }
}; 