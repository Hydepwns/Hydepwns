/**
 * Event Manager Component Tests
 * ------------------------
 * Tests for the EventManager component that handles event registration and management.
 */

import { EventManagerComponent } from '../../../assets/js/components/event_manager';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('EventManager Component', () => {
  let testContainer;
  let component;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the event manager element
    const managerElement = document.createElement('div');
    managerElement.className = 'event-manager';
    testContainer.appendChild(managerElement);
    
    // Initialize the component
    component = new EventManagerComponent(managerElement);
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    
    if (testContainer && testContainer.parentNode) {
      testContainer.parentNode.removeChild(testContainer);
    }
    
    sinon.restore();
  });
  
  describe('Event Registration', () => {
    it('registers event handlers', () => {
      const handler = sinon.spy();
      const subscription = component.on('test-event', handler);
      
      expect(subscription).toBeDefined();
      expect(typeof subscription.unsubscribe).toBe('function');
    });
    
    it('handles multiple event handlers', () => {
      const handler1 = sinon.spy();
      const handler2 = sinon.spy();
      
      component.on('test-event', handler1);
      component.on('test-event', handler2);
      
      component.emit('test-event', { data: 'test' });
      
      expect(handler1.calledOnce).toBe(true);
      expect(handler2.calledOnce).toBe(true);
    });
    
    it('unsubscribes event handlers', () => {
      const handler = sinon.spy();
      const subscription = component.on('test-event', handler);
      
      subscription.unsubscribe();
      component.emit('test-event', { data: 'test' });
      
      expect(handler.called).toBe(false);
    });
  });
  
  describe('Event Emission', () => {
    it('emits events with data', () => {
      const handler = sinon.spy();
      component.on('test-event', handler);
      
      const eventData = { data: 'test' };
      component.emit('test-event', eventData);
      
      expect(handler.calledWith(eventData)).toBe(true);
    });
    
    it('handles events without data', () => {
      const handler = sinon.spy();
      component.on('test-event', handler);
      
      component.emit('test-event');
      
      expect(handler.calledOnce).toBe(true);
    });
  });
  
  describe('Error Handling', () => {
    it('catches errors in event handlers', () => {
      const errorHandler = sinon.spy();
      component.onError(errorHandler);
      
      const handler = () => {
        throw new Error('Test error');
      };
      
      component.on('test-event', handler);
      component.emit('test-event');
      
      expect(errorHandler.calledOnce).toBe(true);
    });
    
    it('continues event processing after handler error', () => {
      const errorHandler = sinon.spy();
      component.onError(errorHandler);
      
      const handler1 = () => {
        throw new Error('Test error');
      };
      const handler2 = sinon.spy();
      
      component.on('test-event', handler1);
      component.on('test-event', handler2);
      
      component.emit('test-event');
      
      expect(handler2.calledOnce).toBe(true);
    });
  });
  
  describe('LiveView Hook Integration', () => {
    it('implements the mounted lifecycle method', () => {
      const initializeSpy = sinon.spy(component, 'initialize');
      
      component.mounted();
      expect(initializeSpy.calledOnce).toBe(true);
    });
    
    it('implements the destroyed lifecycle method', () => {
      const destroySpy = sinon.spy(component, 'destroy');
      
      component.initialize();
      component.destroyed();
      
      expect(destroySpy.calledOnce).toBe(true);
    });
  });
}); 