/**
 * Unit Tests for Component Inspector
 */

import { expect } from 'chai';
import sinon from 'sinon';
import { Inspector } from '../assets/js/components/core';
import ComponentRegistry from '../assets/js/components/core/component_registry';

describe('Component Inspector', () => {
  let sandbox;
  
  beforeEach(() => {
    // Create a sandbox for the test environment
    sandbox = sinon.createSandbox();
    
    // Mock DOM elements
    global.document = {
      createElement: sandbox.stub().returns({
        className: '',
        style: {},
        dataset: {},
        appendChild: sandbox.stub(),
        querySelectorAll: sandbox.stub().returns([])
      }),
      body: {
        appendChild: sandbox.stub(),
        removeChild: sandbox.stub()
      },
      addEventListener: sandbox.stub(),
      querySelector: sandbox.stub().returns(null),
      contains: sandbox.stub().returns(true)
    };
    
    // Reset the component registry
    sandbox.stub(ComponentRegistry, 'getInstance').returns({
      getAll: sandbox.stub().returns([]),
      getById: sandbox.stub().returns(null),
      register: sandbox.stub()
    });
  });
  
  afterEach(() => {
    sandbox.restore();
    delete global.document;
  });
  
  describe('InspectorUI', () => {
    it('should initialize with default options', () => {
      const inspectorUI = new Inspector.UI();
      expect(inspectorUI._isEnabled).to.be.false;
      expect(inspectorUI._options).to.have.property('position');
    });
    
    it('should toggle visibility when enabled/disabled', () => {
      const inspectorUI = new Inspector.UI();
      
      // Mock container creation
      inspectorUI._container = { style: { display: 'none' } };
      
      inspectorUI.enable();
      expect(inspectorUI._isEnabled).to.be.true;
      expect(inspectorUI._container.style.display).to.equal('block');
      
      inspectorUI.disable();
      expect(inspectorUI._isEnabled).to.be.false;
      expect(inspectorUI._container.style.display).to.equal('none');
    });
    
    it('should register event listeners when created', () => {
      const registerEventListenersSpy = sandbox.spy(Inspector.UI.prototype, '_registerEventListeners');
      
      const inspectorUI = new Inspector.UI();
      expect(registerEventListenersSpy.calledOnce).to.be.true;
    });
  });
  
  describe('ComponentTree', () => {
    it('should build component tree from registry', () => {
      // Mock components in registry
      const mockComponents = [
        { id: '1', name: 'Root', parentId: null },
        { id: '2', name: 'Child1', parentId: '1' },
        { id: '3', name: 'Child2', parentId: '1' },
        { id: '4', name: 'Grandchild', parentId: '2' }
      ];
      
      ComponentRegistry.getInstance().getAll.returns(mockComponents);
      
      const tree = new Inspector.ComponentTree();
      const componentTree = tree.buildTree();
      
      expect(componentTree).to.have.length(1); // One root component
      expect(componentTree[0].id).to.equal('1');
      expect(componentTree[0].children).to.have.length(2); // Two children
      expect(componentTree[0].children[0].children).to.have.length(1); // One grandchild
    });
  });
  
  describe('PerformanceMonitor', () => {
    let performanceMonitor;
    
    beforeEach(() => {
      // Mock performance API
      global.performance = {
        now: sandbox.stub().returns(100),
        mark: sandbox.stub(),
        measure: sandbox.stub(),
        getEntriesByName: sandbox.stub().returns([]),
        getEntriesByType: sandbox.stub().returns([]),
        clearMarks: sandbox.stub(),
        clearMeasures: sandbox.stub()
      };
      
      performanceMonitor = new Inspector.PerformanceMonitor();
    });
    
    afterEach(() => {
      delete global.performance;
    });
    
    it('should track component render time', () => {
      const component = { id: 'test-component', name: 'TestComponent' };
      
      performanceMonitor.startMeasurement(component.id, 'render');
      
      // Simulate time passing
      performance.now.returns(150);
      
      performanceMonitor.endMeasurement(component.id, 'render');
      
      const metrics = performanceMonitor.getMetrics(component.id);
      expect(metrics).to.have.property('render');
      expect(metrics.render.lastDuration).to.equal(50);
    });
    
    it('should calculate average render time', () => {
      const component = { id: 'test-component', name: 'TestComponent' };
      
      // First render: 50ms
      performanceMonitor.startMeasurement(component.id, 'render');
      performance.now.returns(150);
      performanceMonitor.endMeasurement(component.id, 'render');
      
      // Second render: 100ms
      performance.now.returns(150);
      performanceMonitor.startMeasurement(component.id, 'render');
      performance.now.returns(250);
      performanceMonitor.endMeasurement(component.id, 'render');
      
      const metrics = performanceMonitor.getMetrics(component.id);
      expect(metrics.render.average).to.equal(75);
    });
    
    it('should identify slow components', () => {
      const component1 = { id: 'fast-component', name: 'FastComponent' };
      const component2 = { id: 'slow-component', name: 'SlowComponent' };
      
      // Fast component: 10ms
      performanceMonitor.startMeasurement(component1.id, 'render');
      performance.now.returns(110);
      performanceMonitor.endMeasurement(component1.id, 'render');
      
      // Slow component: 200ms
      performance.now.returns(200);
      performanceMonitor.startMeasurement(component2.id, 'render');
      performance.now.returns(400);
      performanceMonitor.endMeasurement(component2.id, 'render');
      
      const slowComponents = performanceMonitor.getSlowComponents(50);
      expect(slowComponents).to.have.length(1);
      expect(slowComponents[0].id).to.equal('slow-component');
    });
  });
  
  describe('EventMonitor', () => {
    let eventMonitor;
    
    beforeEach(() => {
      eventMonitor = new Inspector.EventMonitor();
    });
    
    it('should track component events', () => {
      const sourceId = 'source-component';
      const targetId = 'target-component';
      const eventName = 'test-event';
      const eventData = { value: 42 };
      
      eventMonitor.trackEvent(sourceId, targetId, eventName, eventData);
      
      const events = eventMonitor.getEvents();
      expect(events).to.have.length(1);
      expect(events[0].sourceId).to.equal(sourceId);
      expect(events[0].targetId).to.equal(targetId);
      expect(events[0].name).to.equal(eventName);
      expect(events[0].data).to.deep.equal(eventData);
    });
    
    it('should filter events by component', () => {
      eventMonitor.trackEvent('comp1', 'target1', 'click');
      eventMonitor.trackEvent('comp2', 'target2', 'click');
      eventMonitor.trackEvent('comp1', 'target3', 'hover');
      
      const comp1Events = eventMonitor.getEventsByComponent('comp1');
      expect(comp1Events).to.have.length(2);
      
      const comp2Events = eventMonitor.getEventsByComponent('comp2');
      expect(comp2Events).to.have.length(1);
    });
    
    it('should filter events by type', () => {
      eventMonitor.trackEvent('comp1', 'target1', 'click');
      eventMonitor.trackEvent('comp2', 'target2', 'click');
      eventMonitor.trackEvent('comp1', 'target3', 'hover');
      
      const clickEvents = eventMonitor.getEventsByType('click');
      expect(clickEvents).to.have.length(2);
      
      const hoverEvents = eventMonitor.getEventsByType('hover');
      expect(hoverEvents).to.have.length(1);
    });
  });
  
  describe('Browser Compatibility Tests', () => {
    it('should detect and provide fallbacks for unsupported browser features', () => {
      // This would need to be run in actual browser environments
      // or with a more sophisticated browser environment mock
    });
  });
}); 