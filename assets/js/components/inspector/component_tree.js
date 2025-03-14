/**
 * Component Tree Visualization
 * 
 * Provides visualization tools for component relationships and hierarchies.
 * Allows interactive exploration of the component tree.
 */

import ComponentRegistry from '../core/component_registry';

class ComponentTree {
  constructor() {
    this._container = null;
    this._svgElement = null;
    this._tooltipElement = null;
    this._width = 800;
    this._height = 600;
    this._padding = 50;
    this._nodeRadius = 15;
    this._selectedNodeId = null;
    this._zoomLevel = 1;
    this._panOffset = { x: 0, y: 0 };
    this._isDragging = false;
    this._dragStart = { x: 0, y: 0 };
    
    // Tree layout properties
    this._treeLayout = {
      nodeSpacing: 80,
      levelSpacing: 120
    };
    
    // Visualization data
    this._nodes = [];
    this._edges = [];
    
    // Mouse event handlers
    this._handleMouseDown = this._handleMouseDown.bind(this);
    this._handleMouseMove = this._handleMouseMove.bind(this);
    this._handleMouseUp = this._handleMouseUp.bind(this);
    this._handleMouseWheel = this._handleMouseWheel.bind(this);
    this._handleNodeClick = this._handleNodeClick.bind(this);
    this._handleNodeMouseEnter = this._handleNodeMouseEnter.bind(this);
    this._handleNodeMouseLeave = this._handleNodeMouseLeave.bind(this);
  }
  
  /**
   * Initialize the component tree visualization
   * @param {HTMLElement} container - Container element for the visualization
   * @param {Object} options - Visualization options
   */
  initialize(container, options = {}) {
    this._container = container;
    
    // Apply options
    this._width = options.width || this._width;
    this._height = options.height || this._height;
    this._nodeRadius = options.nodeRadius || this._nodeRadius;
    
    // Create SVG element
    this._createSvgElement();
    
    // Create tooltip
    this._createTooltip();
    
    // Register event listeners
    this._registerEventListeners();
    
    // Initial render
    this.refresh();
  }
  
  /**
   * Refresh the component tree visualization
   */
  refresh() {
    if (!this._svgElement) return;
    
    // Get component data from registry
    this._buildComponentData();
    
    // Calculate layout
    this._calculateLayout();
    
    // Render visualization
    this._render();
  }
  
  /**
   * Set the selected node
   * @param {String} nodeId - Node ID
   */
  selectNode(nodeId) {
    this._selectedNodeId = nodeId;
    this._render();
    
    // Fire event
    if (this._container) {
      const event = new CustomEvent('node-selected', { 
        detail: { nodeId, node: this._findNodeById(nodeId) }
      });
      this._container.dispatchEvent(event);
    }
  }
  
  /**
   * Zoom to specific level
   * @param {Number} level - Zoom level (1 = 100%)
   */
  zoom(level) {
    this._zoomLevel = Math.max(0.1, Math.min(2, level));
    this._render();
  }
  
  /**
   * Reset view
   */
  resetView() {
    this._zoomLevel = 1;
    this._panOffset = { x: 0, y: 0 };
    this._render();
  }
  
  /**
   * Get the current component data
   * @returns {Object} - Component data
   */
  getData() {
    return {
      nodes: [...this._nodes],
      edges: [...this._edges]
    };
  }
  
  /**
   * Cleanup resources
   */
  destroy() {
    this._unregisterEventListeners();
    
    if (this._svgElement && this._container) {
      this._container.removeChild(this._svgElement);
    }
    
    if (this._tooltipElement && this._container) {
      this._container.removeChild(this._tooltipElement);
    }
    
    this._svgElement = null;
    this._tooltipElement = null;
    this._container = null;
  }
  
  /**
   * Create SVG element for the visualization
   * @private
   */
  _createSvgElement() {
    // Remove existing SVG if any
    if (this._svgElement && this._container) {
      this._container.removeChild(this._svgElement);
    }
    
    // Create new SVG
    this._svgElement = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    this._svgElement.setAttribute('width', '100%');
    this._svgElement.setAttribute('height', '100%');
    this._svgElement.setAttribute('viewBox', `0 0 ${this._width} ${this._height}`);
    this._svgElement.style.cursor = 'grab';
    
    // Add to container
    this._container.appendChild(this._svgElement);
  }
  
  /**
   * Create tooltip element
   * @private
   */
  _createTooltip() {
    // Remove existing tooltip if any
    if (this._tooltipElement && this._container) {
      this._container.removeChild(this._tooltipElement);
    }
    
    // Create new tooltip
    this._tooltipElement = document.createElement('div');
    this._tooltipElement.className = 'component-tree-tooltip';
    this._tooltipElement.style.cssText = `
      position: absolute;
      display: none;
      background-color: rgba(0, 0, 0, 0.8);
      color: white;
      padding: 8px 12px;
      border-radius: 4px;
      font-size: 14px;
      pointer-events: none;
      z-index: 1000;
      max-width: 250px;
    `;
    
    // Add to container
    this._container.appendChild(this._tooltipElement);
  }
  
  /**
   * Register event listeners
   * @private
   */
  _registerEventListeners() {
    if (!this._svgElement || !this._container) return;
    
    // Pan and zoom
    this._svgElement.addEventListener('mousedown', this._handleMouseDown);
    document.addEventListener('mousemove', this._handleMouseMove);
    document.addEventListener('mouseup', this._handleMouseUp);
    this._svgElement.addEventListener('wheel', this._handleMouseWheel);
    
    // Prevent context menu
    this._svgElement.addEventListener('contextmenu', e => e.preventDefault());
  }
  
  /**
   * Unregister event listeners
   * @private
   */
  _unregisterEventListeners() {
    if (!this._svgElement) return;
    
    this._svgElement.removeEventListener('mousedown', this._handleMouseDown);
    document.removeEventListener('mousemove', this._handleMouseMove);
    document.removeEventListener('mouseup', this._handleMouseUp);
    this._svgElement.removeEventListener('wheel', this._handleMouseWheel);
  }
  
  /**
   * Handle mouse down event
   * @param {MouseEvent} event - Mouse event
   * @private
   */
  _handleMouseDown(event) {
    // Only handle middle or right mouse button for panning
    if (event.button === 1 || event.button === 2) {
      this._isDragging = true;
      this._dragStart = { x: event.clientX, y: event.clientY };
      this._svgElement.style.cursor = 'grabbing';
      event.preventDefault();
    }
  }
  
  /**
   * Handle mouse move event
   * @param {MouseEvent} event - Mouse event
   * @private
   */
  _handleMouseMove(event) {
    if (this._isDragging) {
      const dx = event.clientX - this._dragStart.x;
      const dy = event.clientY - this._dragStart.y;
      
      this._panOffset.x += dx / this._zoomLevel;
      this._panOffset.y += dy / this._zoomLevel;
      
      this._dragStart = { x: event.clientX, y: event.clientY };
      
      this._render();
    }
  }
  
  /**
   * Handle mouse up event
   * @param {MouseEvent} event - Mouse event
   * @private
   */
  _handleMouseUp() {
    this._isDragging = false;
    if (this._svgElement) {
      this._svgElement.style.cursor = 'grab';
    }
  }
  
  /**
   * Handle mouse wheel event
   * @param {WheelEvent} event - Wheel event
   * @private
   */
  _handleMouseWheel(event) {
    event.preventDefault();
    
    // Calculate zoom factor
    const delta = -Math.sign(event.deltaY) * 0.1;
    const newZoom = Math.max(0.1, Math.min(2, this._zoomLevel + delta));
    
    // Calculate mouse position relative to SVG
    const rect = this._svgElement.getBoundingClientRect();
    const mouseX = ((event.clientX - rect.left) / rect.width) * this._width;
    const mouseY = ((event.clientY - rect.top) / rect.height) * this._height;
    
    // Adjust pan offset to zoom towards mouse position
    if (newZoom !== this._zoomLevel) {
      const zoomRatio = newZoom / this._zoomLevel;
      const panX = mouseX - this._panOffset.x;
      const panY = mouseY - this._panOffset.y;
      
      this._panOffset.x = mouseX - panX * zoomRatio;
      this._panOffset.y = mouseY - panY * zoomRatio;
      this._zoomLevel = newZoom;
      
      this._render();
    }
  }
  
  /**
   * Handle node click event
   * @param {String} nodeId - Node ID
   * @private
   */
  _handleNodeClick(nodeId) {
    this.selectNode(nodeId);
  }
  
  /**
   * Handle node mouse enter event
   * @param {MouseEvent} event - Mouse event
   * @param {Object} node - Node data
   * @private
   */
  _handleNodeMouseEnter(event, node) {
    if (!this._tooltipElement) return;
    
    // Update tooltip content
    this._tooltipElement.innerHTML = `
      <div><strong>${node.name || 'Component'}</strong></div>
      <div>ID: ${node.id}</div>
      <div>Type: ${node.type || 'Unknown'}</div>
      <div>Children: ${node.children ? node.children.length : 0}</div>
    `;
    
    // Position tooltip
    const rect = this._container.getBoundingClientRect();
    this._tooltipElement.style.left = `${event.clientX - rect.left + 10}px`;
    this._tooltipElement.style.top = `${event.clientY - rect.top + 10}px`;
    
    // Show tooltip
    this._tooltipElement.style.display = 'block';
  }
  
  /**
   * Handle node mouse leave event
   * @private
   */
  _handleNodeMouseLeave() {
    if (this._tooltipElement) {
      this._tooltipElement.style.display = 'none';
    }
  }
  
  /**
   * Build component data from registry
   * @private
   */
  _buildComponentData() {
    const registry = ComponentRegistry.getInstance();
    const components = registry.getAll();
    
    // Reset data
    this._nodes = [];
    this._edges = [];
    
    // Create nodes
    components.forEach(component => {
      this._nodes.push({
        id: component.id,
        name: component.name || 'Component',
        type: component.constructor ? component.constructor.name : 'Component',
        parentId: component.parentId,
        children: [],
        x: 0,
        y: 0
      });
    });
    
    // Build tree structure
    this._nodes.forEach(node => {
      if (node.parentId) {
        const parent = this._findNodeById(node.parentId);
        if (parent) {
          parent.children.push(node);
        }
      }
    });
    
    // Create edges based on parent-child relationships
    this._nodes.forEach(node => {
      if (node.parentId) {
        this._edges.push({
          id: `${node.parentId}-${node.id}`,
          source: node.parentId,
          target: node.id,
          type: 'parent-child'
        });
      }
    });
  }
  
  /**
   * Find a node by ID
   * @param {String} id - Node ID
   * @returns {Object|null} - Node or null if not found
   * @private
   */
  _findNodeById(id) {
    return this._nodes.find(node => node.id === id);
  }
  
  /**
   * Calculate layout for visualization
   * @private
   */
  _calculateLayout() {
    // Find root nodes (nodes without parents or with parents not in the tree)
    const rootNodes = this._nodes.filter(node => {
      if (!node.parentId) return true;
      return !this._findNodeById(node.parentId);
    });
    
    // Assign levels to nodes (depth in the tree)
    rootNodes.forEach(node => {
      this._assignLevels(node, 0);
    });
    
    // Sort nodes within each level
    const nodesByLevel = {};
    this._nodes.forEach(node => {
      if (!nodesByLevel[node.level]) {
        nodesByLevel[node.level] = [];
      }
      nodesByLevel[node.level].push(node);
    });
    
    // Calculate horizontal positions
    const levels = Object.keys(nodesByLevel).map(Number).sort((a, b) => a - b);
    levels.forEach(level => {
      const nodesInLevel = nodesByLevel[level];
      const totalWidth = (nodesInLevel.length - 1) * this._treeLayout.nodeSpacing;
      const startX = (this._width - totalWidth) / 2;
      
      nodesInLevel.forEach((node, i) => {
        node.x = startX + i * this._treeLayout.nodeSpacing;
        node.y = this._padding + level * this._treeLayout.levelSpacing;
      });
    });
  }
  
  /**
   * Assign levels to nodes
   * @param {Object} node - Node
   * @param {Number} level - Level
   * @private
   */
  _assignLevels(node, level) {
    node.level = level;
    
    if (node.children && node.children.length > 0) {
      node.children.forEach(child => {
        this._assignLevels(child, level + 1);
      });
    }
  }
  
  /**
   * Render the visualization
   * @private
   */
  _render() {
    if (!this._svgElement) return;
    
    // Clear SVG
    this._svgElement.innerHTML = '';
    
    // Create transform group for panning and zooming
    const transform = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    transform.setAttribute('transform', `translate(${this._panOffset.x},${this._panOffset.y}) scale(${this._zoomLevel})`);
    this._svgElement.appendChild(transform);
    
    // Draw edges first (so they're underneath nodes)
    this._renderEdges(transform);
    
    // Draw nodes
    this._renderNodes(transform);
  }
  
  /**
   * Render edges
   * @param {SVGElement} container - Container element
   * @private
   */
  _renderEdges(container) {
    this._edges.forEach(edge => {
      const source = this._findNodeById(edge.source);
      const target = this._findNodeById(edge.target);
      
      if (source && target) {
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', source.x);
        line.setAttribute('y1', source.y);
        line.setAttribute('x2', target.x);
        line.setAttribute('y2', target.y);
        line.setAttribute('stroke', '#999');
        line.setAttribute('stroke-width', '2');
        
        container.appendChild(line);
      }
    });
  }
  
  /**
   * Render nodes
   * @param {SVGElement} container - Container element
   * @private
   */
  _renderNodes(container) {
    this._nodes.forEach(node => {
      // Create group for node
      const nodeGroup = document.createElementNS('http://www.w3.org/2000/svg', 'g');
      nodeGroup.setAttribute('transform', `translate(${node.x},${node.y})`);
      nodeGroup.setAttribute('data-node-id', node.id);
      nodeGroup.style.cursor = 'pointer';
      
      // Create circle
      const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
      circle.setAttribute('r', this._nodeRadius);
      circle.setAttribute('fill', node.id === this._selectedNodeId ? '#3a71c8' : '#666');
      circle.setAttribute('stroke', '#fff');
      circle.setAttribute('stroke-width', '2');
      
      // Create label
      const label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      label.setAttribute('text-anchor', 'middle');
      label.setAttribute('dy', '0.3em');
      label.setAttribute('fill', '#fff');
      label.setAttribute('font-size', '10');
      label.textContent = node.name.charAt(0).toUpperCase();
      
      // Create name label below node
      const nameLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      nameLabel.setAttribute('text-anchor', 'middle');
      nameLabel.setAttribute('dy', '25');
      nameLabel.setAttribute('fill', '#333');
      nameLabel.setAttribute('font-size', '12');
      nameLabel.textContent = node.name;
      
      // Add event listeners
      nodeGroup.addEventListener('click', () => this._handleNodeClick(node.id));
      nodeGroup.addEventListener('mouseenter', (e) => this._handleNodeMouseEnter(e, node));
      nodeGroup.addEventListener('mouseleave', this._handleNodeMouseLeave);
      
      // Add to container
      nodeGroup.appendChild(circle);
      nodeGroup.appendChild(label);
      nodeGroup.appendChild(nameLabel);
      container.appendChild(nodeGroup);
    });
  }
}

// Singleton instance
let instance = null;

export default {
  getInstance() {
    if (!instance) {
      instance = new ComponentTree();
    }
    return instance;
  }
}; 