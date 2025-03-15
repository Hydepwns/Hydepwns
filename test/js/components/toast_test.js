/**
 * Toast Component Tests
 * ------------------------
 * Tests for the Toast component that provides temporary notification messages.
 */

import { ToastComponent } from '../../../assets/js/components/toast';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('Toast Component', () => {
  let testContainer;
  let component;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the toast container element
    const toastElement = document.createElement('div');
    toastElement.className = 'toast-container';
    toastElement.setAttribute('data-position', 'top-right');
    testContainer.appendChild(toastElement);
    
    // Initialize the component
    component = new ToastComponent(toastElement);
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
  
  describe('Initialization', () => {
    it('initializes with the correct options', () => {
      expect(component).toBeDefined();
      expect(component.element).toBeDefined();
      expect(component.options.position).toBe('top-right');
    });
    
    it('creates toast container structure', () => {
      component.initialize();
      
      const container = document.querySelector('.toast-container');
      expect(container).toBeDefined();
      expect(container.classList.contains('position-top-right')).toBe(true);
    });
    
    it('sets default options when not provided', () => {
      const defaultElement = document.createElement('div');
      defaultElement.className = 'toast-container';
      testContainer.appendChild(defaultElement);
      
      const defaultComponent = new ToastComponent(defaultElement);
      
      expect(defaultComponent.options.position).toBe('top-right');
      expect(defaultComponent.options.duration).toBe(3000);
      expect(defaultComponent.options.maxToasts).toBe(5);
      
      defaultComponent.destroy();
    });
  });
  
  describe('Toast Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('shows toast message', () => {
      component.show('Test message');
      
      const toast = document.querySelector('.toast');
      expect(toast).toBeDefined();
      expect(toast.textContent).toContain('Test message');
    });
    
    it('shows toast with type', () => {
      component.show('Success message', { type: 'success' });
      
      const toast = document.querySelector('.toast');
      expect(toast.classList.contains('toast-success')).toBe(true);
    });
    
    it('limits number of toasts', () => {
      for (let i = 0; i < 7; i++) {
        component.show(`Message ${i}`);
      }
      
      const toasts = document.querySelectorAll('.toast');
      expect(toasts.length).toBe(5); // maxToasts default value
    });
  });
  
  describe('Toast Lifecycle', () => {
    beforeEach(() => {
      component.initialize();
      // Use fake timers
      jest.useFakeTimers();
    });
    
    afterEach(() => {
      jest.useRealTimers();
    });
    
    it('auto-dismisses toast after duration', () => {
      component.show('Test message');
      
      expect(document.querySelectorAll('.toast').length).toBe(1);
      
      jest.advanceTimersByTime(3000);
      
      expect(document.querySelectorAll('.toast').length).toBe(0);
    });
    
    it('handles manual dismissal', () => {
      component.show('Test message');
      
      const toast = document.querySelector('.toast');
      const closeButton = toast.querySelector('.toast-close');
      fireEvent.click(closeButton);
      
      expect(document.querySelectorAll('.toast').length).toBe(0);
    });
    
    it('pauses auto-dismiss on hover', () => {
      component.show('Test message');
      
      const toast = document.querySelector('.toast');
      fireEvent.mouseEnter(toast);
      
      jest.advanceTimersByTime(3000);
      expect(document.querySelectorAll('.toast').length).toBe(1);
      
      fireEvent.mouseLeave(toast);
      jest.advanceTimersByTime(3000);
      expect(document.querySelectorAll('.toast').length).toBe(0);
    });
  });
  
  describe('Toast Animation', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('adds enter animation class', () => {
      component.show('Test message');
      
      const toast = document.querySelector('.toast');
      expect(toast.classList.contains('toast-enter')).toBe(true);
    });
    
    it('adds exit animation class on dismiss', () => {
      component.show('Test message');
      
      const toast = document.querySelector('.toast');
      component.dismiss(toast);
      
      expect(toast.classList.contains('toast-exit')).toBe(true);
    });
  });
  
  describe('Toast Positioning', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('updates container position', () => {
      component.setPosition('bottom-left');
      
      const container = document.querySelector('.toast-container');
      expect(container.classList.contains('position-bottom-left')).toBe(true);
      expect(container.classList.contains('position-top-right')).toBe(false);
    });
    
    it('stacks toasts in correct order', () => {
      component.show('First message');
      component.show('Second message');
      component.show('Third message');
      
      const toasts = document.querySelectorAll('.toast');
      expect(toasts[0].textContent).toContain('Third message');
      expect(toasts[2].textContent).toContain('First message');
    });
  });
  
  describe('Toast Events', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('emits show event', () => {
      const showHandler = sinon.spy();
      component.on('show', showHandler);
      
      component.show('Test message');
      
      expect(showHandler.calledOnce).toBe(true);
      expect(showHandler.firstCall.args[0].message).toBe('Test message');
    });
    
    it('emits dismiss event', () => {
      const dismissHandler = sinon.spy();
      component.on('dismiss', dismissHandler);
      
      const toast = component.show('Test message');
      component.dismiss(toast);
      
      expect(dismissHandler.calledOnce).toBe(true);
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