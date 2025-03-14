/**
 * ResourceCard Component Tests
 * -----------------------
 * Tests for the ResourceCard component that displays resource information.
 */

import { ResourceCardComponent } from '../../../assets/js/components/resource_card';
import sinon from 'sinon';

// Create mock DOM elements
const createMockElement = () => ({
  appendChild: jest.fn(),
  classList: {
    add: jest.fn(),
    remove: jest.fn(),
    contains: jest.fn()
  },
  insertBefore: jest.fn(),
  innerHTML: '',
  firstChild: null
});

// Mock the required modules
jest.mock('../../../assets/js/components/event_manager', () => ({
  registerComponent: jest.fn().mockReturnValue({
    addEventListener: jest.fn(),
    addDelegatedEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    cleanup: jest.fn()
  }),
  unregisterComponent: jest.fn()
}));

jest.mock('../../../assets/js/utils/dom_cleanup', () => ({
  register: jest.fn().mockReturnValue({
    registerElement: jest.fn(),
    registerInterval: jest.fn(),
    registerTimeout: jest.fn(),
    cleanup: jest.fn()
  }),
  createElement: jest.fn().mockImplementation(() => createMockElement())
}));

describe('ResourceCard Component', () => {
  // This is a simplified test suite that only checks the API of the component
  // Full DOM testing would require more complex mocking of the DOM API
  
  let container;
  let sampleResource;
  let onViewSpy, onEditSpy, onDeleteSpy;
  
  beforeEach(() => {
    // Create a mock container
    container = createMockElement();
    
    // Create sample resource data
    sampleResource = {
      id: '123',
      type: 'TestResource',
      name: 'Test Resource',
      status: 'active',
      properties: {
        field1: 'value1',
        field2: 'value2'
      }
    };
    
    // Create spy functions for callbacks
    onViewSpy = sinon.spy();
    onEditSpy = sinon.spy();
    onDeleteSpy = sinon.spy();
  });
  
  it('has the expected public API', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource
    });
    
    // Check that the component has the expected public methods
    expect(typeof component.mount).toBe('function');
    expect(typeof component.destroy).toBe('function');
    expect(typeof component.updateResource).toBe('function');
    expect(typeof component.toggleExpand).toBe('function');
    expect(typeof component.mounted).toBe('function');
    expect(typeof component.destroyed).toBe('function');
  });
  
  it('initializes with the provided options', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource,
      onView: onViewSpy,
      onEdit: onEditSpy,
      onDelete: onDeleteSpy,
      showActions: true,
      actionTypes: ['view', 'edit'],
      expandable: false
    });
    
    // Check that options are stored correctly
    expect(component.options.resource).toBe(sampleResource);
    expect(component.options.onView).toBe(onViewSpy);
    expect(component.options.onEdit).toBe(onEditSpy);
    expect(component.options.onDelete).toBe(onDeleteSpy);
    expect(component.options.showActions).toBe(true);
    expect(component.options.actionTypes).toEqual(['view', 'edit']);
    expect(component.options.expandable).toBe(false);
  });
  
  it('initializes with default options when not provided', () => {
    const component = new ResourceCardComponent(container);
    
    // Check default options
    expect(component.options.resource).toEqual({});
    expect(typeof component.options.onView).toBe('function');
    expect(typeof component.options.onEdit).toBe('function');
    expect(typeof component.options.onDelete).toBe('function');
    expect(component.options.showActions).toBe(true);
    expect(Array.isArray(component.options.actionTypes)).toBe(true);
    expect(component.options.expandable).toBe(true);
  });
  
  it('updates resource data through updateResource method', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource
    });
    
    // Mock the _render method to avoid DOM operations
    component._render = jest.fn();
    
    const updatedResource = {
      ...sampleResource,
      name: 'Updated Resource',
      status: 'inactive'
    };
    
    component.updateResource(updatedResource);
    
    expect(component.options.resource).toBe(updatedResource);
    expect(component._render).toHaveBeenCalled();
  });
  
  it('toggles expanded state through toggleExpand method', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource
    });
    
    // Mock methods that interact with DOM
    component._updateExpandButton = jest.fn();
    
    // Should start collapsed
    expect(component._state.isExpanded).toBe(false);
    
    // Toggle to expanded
    component.toggleExpand();
    expect(component._state.isExpanded).toBe(true);
    
    // Toggle back to collapsed
    component.toggleExpand();
    expect(component._state.isExpanded).toBe(false);
  });
  
  it('calls the view callback when _handleViewClick is triggered', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource,
      onView: onViewSpy
    });
    
    component._handleViewClick();
    
    expect(onViewSpy.calledOnce).toBe(true);
    expect(onViewSpy.calledWith(sampleResource)).toBe(true);
  });
  
  it('calls the edit callback when _handleEditClick is triggered', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource,
      onEdit: onEditSpy
    });
    
    component._handleEditClick();
    
    expect(onEditSpy.calledOnce).toBe(true);
    expect(onEditSpy.calledWith(sampleResource)).toBe(true);
  });
  
  it('handles delete confirmation flow correctly', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource,
      onDelete: onDeleteSpy
    });
    
    // Mock render actions
    component._renderActions = jest.fn();
    
    // Initial state should be not confirming
    expect(component._state.isConfirmingDelete).toBe(false);
    
    // First click should set to confirming
    component._handleDeleteClick();
    expect(component._state.isConfirmingDelete).toBe(true);
    expect(onDeleteSpy.called).toBe(false);
    
    // Second click should trigger delete and reset confirmation
    component._handleDeleteClick();
    expect(component._state.isConfirmingDelete).toBe(false);
    expect(onDeleteSpy.calledOnce).toBe(true);
    expect(onDeleteSpy.calledWith(sampleResource)).toBe(true);
  });
  
  it('calls mount method when mounted LiveView hook is triggered', () => {
    // Create component
    const component = new ResourceCardComponent(container, {
      resource: sampleResource
    });
    
    // Override mount method to avoid DOM operations
    component.mount = jest.fn();
    
    // Call the mounted method (which would be called by LiveView)
    component.mounted();
    
    expect(component.mount).toHaveBeenCalled();
  });
  
  it('calls destroy method when destroyed LiveView hook is triggered', () => {
    const component = new ResourceCardComponent(container, {
      resource: sampleResource
    });
    
    // Override destroy method to avoid cleanup operations
    component.destroy = jest.fn();
    
    // Call the destroyed method (which would be called by LiveView)
    component.destroyed();
    
    expect(component.destroy).toHaveBeenCalled();
  });
}); 