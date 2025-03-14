/**
 * ResourceCard Component
 * ---------------------
 * 
 * A component that displays information about a resource in a card format,
 * with options to view details, edit, and perform other actions on the resource.
 * 
 * Features:
 * - Displays resource properties in a structured format
 * - Provides action buttons for common operations (view, edit, delete)
 * - Shows resource type and ID
 * - Supports custom action buttons
 * - Displays resource status with appropriate styling
 * - Shows relationship indicators
 * 
 * Built using the robust component system.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class ResourceCardComponent {
  /**
   * Create a new ResourceCard component
   * @param {HTMLElement} container - Container element to mount the component in
   * @param {Object} options - Configuration options
   */
  constructor(container, options = {}) {
    // Generate unique component ID
    this.componentId = `resource-card-${Math.random().toString(36).substring(2, 9)}`;
    
    // Store the container
    this.elements = {
      container: container
    };
    
    // Default options merged with user-provided options
    this.options = {
      resource: {},
      onView: () => console.log('View action not implemented'),
      onEdit: () => console.log('Edit action not implemented'),
      onDelete: () => console.log('Delete action not implemented'),
      showActions: true,
      actionTypes: ['view', 'edit', 'delete'],
      expandable: true,
      ...options
    };
    
    // Internal state
    this._state = {
      isExpanded: false,
      isConfirmingDelete: false
    };
    
    // Auto-mount if container is provided
    if (container) {
      // Initialize event manager for this component
      this.events = EventManager.registerComponent(this.componentId);
      
      // Initialize DOM cleanup registry
      this.cleanup = DOMCleanup.register(this.componentId);
    }
  }
  
  /**
   * Initialize the component
   * @returns {ResourceCardComponent} this instance for chaining
   */
  mount() {
    // Initialize event manager and cleanup if not already initialized
    if (!this.events) {
      this.events = EventManager.registerComponent(this.componentId);
    }
    
    if (!this.cleanup) {
      this.cleanup = DOMCleanup.register(this.componentId);
    }
    
    // Build the initial DOM structure
    this._buildDOM();
    
    // Render content
    this._render();
    
    // Set up event listeners
    this._setupEventListeners();
    
    return this;
  }
  
  /**
   * Clean up and destroy the component
   */
  destroy() {
    // Clean up event listeners
    if (this.events) {
      this.events.cleanup();
    }
    
    // Clean up DOM elements
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
  }
  
  /**
   * Update the resource data and re-render
   * @param {Object} resource - New resource data
   * @returns {this} - For method chaining
   */
  updateResource(resource) {
    if (!resource) {
      console.warn('Attempted to update ResourceCard with null resource');
      return this;
    }
    
    this.options.resource = resource;
    this._render();
    
    return this;
  }
  
  /**
   * Toggle the expanded state of the card
   * @returns {this} - For method chaining
   */
  toggleExpand() {
    this._state.isExpanded = !this._state.isExpanded;
    
    if (this.elements.card) {
      if (this._state.isExpanded) {
        this.elements.card.classList.add('resource-card--expanded');
      } else {
        this.elements.card.classList.remove('resource-card--expanded');
      }
    }
    
    this._updateExpandButton();
    
    return this;
  }
  
  /**
   * Build the DOM structure for the component
   * @private
   */
  _buildDOM() {
    if (!this.elements.container) {
      console.error('ResourceCard: No container element provided');
      return;
    }
    
    // Create card container
    this.elements.card = DOMCleanup.createElement('div', {
      className: 'resource-card',
      id: this.componentId,
      'data-resource-id': this.options.resource.id || '',
      'data-resource-type': this.options.resource.type || ''
    }, '', this.cleanup);
    
    // Create card header
    this.elements.header = DOMCleanup.createElement('div', {
      className: 'resource-card__header'
    }, '', this.cleanup);
    
    // Create card body
    this.elements.body = DOMCleanup.createElement('div', {
      className: 'resource-card__body'
    }, '', this.cleanup);
    
    // Create property list
    this.elements.propertyList = DOMCleanup.createElement('div', {
      className: 'resource-card__property-list'
    }, '', this.cleanup);
    
    this.elements.body.appendChild(this.elements.propertyList);
    
    // Create card footer
    this.elements.footer = DOMCleanup.createElement('div', {
      className: 'resource-card__footer'
    }, '', this.cleanup);
    
    // Create expand button if card is expandable
    if (this.options.expandable) {
      this.elements.expandButton = DOMCleanup.createElement('button', {
        className: 'resource-card__expand-btn',
        type: 'button',
        'aria-label': 'Toggle resource details'
      }, 'Show more', this.cleanup);
      
      this.elements.footer.appendChild(this.elements.expandButton);
    }
    
    // Create actions container if actions are enabled
    if (this.options.showActions) {
      this.elements.actionsContainer = DOMCleanup.createElement('div', {
        className: 'resource-card__actions'
      }, '', this.cleanup);
      
      this.elements.footer.appendChild(this.elements.actionsContainer);
    }
    
    // Assemble card
    this.elements.card.appendChild(this.elements.header);
    this.elements.card.appendChild(this.elements.body);
    this.elements.card.appendChild(this.elements.footer);
    
    // Add card to container
    this.elements.container.appendChild(this.elements.card);
  }
  
  /**
   * Render the component content based on current state
   * @private
   */
  _render() {
    if (!this.elements.card) {
      return;
    }
    
    this._renderHeader();
    this._renderProperties();
    this._renderActions();
  }
  
  /**
   * Render the card header with resource type and status
   * @private
   */
  _renderHeader() {
    if (!this.elements.header) return;
    
    // Clear existing content
    this.elements.header.innerHTML = '';
    
    // Get resource type
    const resourceType = this.options.resource.type || 'Resource';
    
    // Create type label
    const typeElement = DOMCleanup.createElement('span', {
      className: 'resource-card__type'
    }, resourceType, this.cleanup);
    
    this.elements.header.appendChild(typeElement);
    
    // Add ID if available
    if (this.options.resource.id) {
      const idElement = DOMCleanup.createElement('span', {
        className: 'resource-card__id'
      }, `#${this.options.resource.id}`, this.cleanup);
      
      this.elements.header.appendChild(idElement);
    }
    
    // Add status if available
    if (this.options.resource.status) {
      const statusElement = DOMCleanup.createElement('span', {
        className: `resource-card__status resource-card__status--${this.options.resource.status.toLowerCase()}`
      }, this.options.resource.status, this.cleanup);
      
      this.elements.header.appendChild(statusElement);
    }
    
    // Add created date if available
    if (this.options.resource.createdAt) {
      const date = new Date(this.options.resource.createdAt);
      const dateFormatter = new Intl.DateTimeFormat('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
      });
      
      const dateElement = DOMCleanup.createElement('span', {
        className: 'resource-card__date'
      }, dateFormatter.format(date), this.cleanup);
      
      this.elements.header.appendChild(dateElement);
    }
  }
  
  /**
   * Render the resource properties
   * @private
   */
  _renderProperties() {
    if (!this.elements.propertyList) return;
    
    // Clear existing content
    this.elements.propertyList.innerHTML = '';
    
    // Get resource properties
    const properties = this.options.resource.properties || {};
    
    // Create a property item for each property
    Object.entries(properties).forEach(([key, value]) => {
      const propertyItem = DOMCleanup.createElement('div', {
        className: 'resource-card__property-item'
      }, '', this.cleanup);
      
      const propertyKey = DOMCleanup.createElement('span', {
        className: 'resource-card__property-key'
      }, key, this.cleanup);
      
      const propertyValue = DOMCleanup.createElement('span', {
        className: 'resource-card__property-value'
      }, String(value), this.cleanup);
      
      propertyItem.appendChild(propertyKey);
      propertyItem.appendChild(propertyValue);
      
      this.elements.propertyList.appendChild(propertyItem);
    });
    
    // Add name property if available
    if (this.options.resource.name && !properties.name) {
      const nameItem = DOMCleanup.createElement('div', {
        className: 'resource-card__property-item resource-card__property-item--name'
      }, '', this.cleanup);
      
      const nameKey = DOMCleanup.createElement('span', {
        className: 'resource-card__property-key'
      }, 'name', this.cleanup);
      
      const nameValue = DOMCleanup.createElement('span', {
        className: 'resource-card__property-value'
      }, this.options.resource.name, this.cleanup);
      
      nameItem.appendChild(nameKey);
      nameItem.appendChild(nameValue);
      
      // Insert name at the top
      this.elements.propertyList.insertBefore(nameItem, this.elements.propertyList.firstChild);
    }
  }
  
  /**
   * Render action buttons
   * @private
   */
  _renderActions() {
    if (!this.options.showActions || !this.elements.actionsContainer) return;
    
    // Clear existing content
    this.elements.actionsContainer.innerHTML = '';
    
    // Create action buttons based on actionTypes
    if (this.options.actionTypes.includes('view')) {
      const viewButton = DOMCleanup.createElement('button', {
        className: 'resource-card__action-btn resource-card__action-btn--view',
        type: 'button'
      }, 'View', this.cleanup);
      
      this.events.addEventListener(viewButton, 'click', this._handleViewClick.bind(this));
      this.elements.actionsContainer.appendChild(viewButton);
    }
    
    if (this.options.actionTypes.includes('edit')) {
      const editButton = DOMCleanup.createElement('button', {
        className: 'resource-card__action-btn resource-card__action-btn--edit',
        type: 'button'
      }, 'Edit', this.cleanup);
      
      this.events.addEventListener(editButton, 'click', this._handleEditClick.bind(this));
      this.elements.actionsContainer.appendChild(editButton);
    }
    
    if (this.options.actionTypes.includes('delete')) {
      const deleteButton = DOMCleanup.createElement('button', {
        className: `resource-card__action-btn resource-card__action-btn--delete ${this._state.isConfirmingDelete ? 'resource-card__action-btn--confirming' : ''}`,
        type: 'button'
      }, this._state.isConfirmingDelete ? 'Confirm' : 'Delete', this.cleanup);
      
      this.events.addEventListener(deleteButton, 'click', this._handleDeleteClick.bind(this));
      this.elements.actionsContainer.appendChild(deleteButton);
    }
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Set up expand button click handler
    if (this.elements.expandButton) {
      this.events.addEventListener(
        this.elements.expandButton, 
        'click', 
        this.toggleExpand.bind(this)
      );
    }
    
    // Set up click outside handler to reset delete confirmation
    document.addEventListener('click', (e) => {
      if (this._state.isConfirmingDelete && 
          this.elements.actionsContainer && 
          !this.elements.actionsContainer.contains(e.target)) {
        this._state.isConfirmingDelete = false;
        this._renderActions();
      }
    });
  }
  
  /**
   * Update expand button text based on current state
   * @private
   */
  _updateExpandButton() {
    if (this.elements.expandButton) {
      this.elements.expandButton.textContent = this._state.isExpanded ? 'Show less' : 'Show more';
    }
  }
  
  /**
   * Handle view button click
   * @private
   */
  _handleViewClick() {
    if (typeof this.options.onView === 'function') {
      this.options.onView(this.options.resource);
    }
  }
  
  /**
   * Handle edit button click
   * @private
   */
  _handleEditClick() {
    if (typeof this.options.onEdit === 'function') {
      this.options.onEdit(this.options.resource);
    }
  }
  
  /**
   * Handle delete button click
   * @private
   */
  _handleDeleteClick() {
    if (this._state.isConfirmingDelete) {
      // If already confirming, execute the delete action
      if (typeof this.options.onDelete === 'function') {
        this.options.onDelete(this.options.resource);
      }
      this._state.isConfirmingDelete = false;
    } else {
      // First click, show confirmation
      this._state.isConfirmingDelete = true;
    }
    
    // Update button state
    this._renderActions();
  }
  
  /**
   * LiveView hook lifecycle method
   */
  mounted() {
    this.mount();
  }
  
  /**
   * LiveView hook lifecycle method
   */
  destroyed() {
    this.destroy();
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const ResourceCard = {
  mounted() {
    const resourceData = JSON.parse(this.el.dataset.resource || '{}');
    const resourceType = this.el.dataset.resourceType || '';
    
    this.component = new ResourceCardComponent(this.el, {
      resource: resourceData,
      resourceType: resourceType,
      showActions: this.el.dataset.showActions !== 'false',
      expandable: this.el.dataset.expandable !== 'false'
    }).mount();
  },
  
  updated() {
    if (this.component) {
      // Update resource data if it changed
      const resourceData = JSON.parse(this.el.dataset.resource || '{}');
      this.component.updateResource(resourceData);
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default ResourceCard;
export { ResourceCardComponent }; 