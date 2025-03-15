/**
 * Tooltip Component Tests
 * ------------------------
 * Tests for the Tooltip component that provides contextual information on hover.
 */

import { TooltipComponent } from '../../../assets/js/components/tooltip';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('Tooltip Component', () => {
  let testContainer;
  let component;
  let triggerElement;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create trigger element with tooltip data
    triggerElement = document.createElement('button');
    triggerElement.textContent = 'Hover me';
    triggerElement.setAttribute('data-tooltip', 'Tooltip content');
    triggerElement.setAttribute('data-tooltip-position', 'top');
    testContainer.appendChild(triggerElement);
    
    // Initialize the component
    component = new TooltipComponent(triggerElement);
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
      expect(component.options.position).toBe('top');
      expect(component.options.content).toBe('Tooltip content');
    });
    
    it('creates tooltip container structure', () => {
      component.initialize();
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip).toBeDefined();
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(true);
    });
    
    it('sets default options when not provided', () => {
      const defaultElement = document.createElement('button');
      defaultElement.setAttribute('data-tooltip', 'Default content');
      testContainer.appendChild(defaultElement);
      
      const defaultComponent = new TooltipComponent(defaultElement);
      
      expect(defaultComponent.options.position).toBe('top');
      expect(defaultComponent.options.delay).toBe(200);
      expect(defaultComponent.options.offset).toBe(10);
      
      defaultComponent.destroy();
    });
  });
  
  describe('Tooltip Display', () => {
    beforeEach(() => {
      component.initialize();
      jest.useFakeTimers();
    });
    
    afterEach(() => {
      jest.useRealTimers();
    });
    
    it('shows tooltip on hover', () => {
      fireEvent.mouseEnter(triggerElement);
      jest.advanceTimersByTime(200);
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(false);
      expect(tooltip.textContent).toBe('Tooltip content');
    });
    
    it('hides tooltip on mouse leave', () => {
      fireEvent.mouseEnter(triggerElement);
      jest.advanceTimersByTime(200);
      fireEvent.mouseLeave(triggerElement);
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(true);
    });
    
    it('respects show delay', () => {
      fireEvent.mouseEnter(triggerElement);
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(true);
      
      jest.advanceTimersByTime(100);
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(true);
      
      jest.advanceTimersByTime(100);
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(false);
    });
  });
  
  describe('Tooltip Positioning', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('positions tooltip correctly', () => {
      component.show();
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.classList.contains('tooltip-position-top')).toBe(true);
    });
    
    it('updates position dynamically', () => {
      component.setPosition('bottom');
      component.show();
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.classList.contains('tooltip-position-bottom')).toBe(true);
    });
    
    it('handles window edge cases', () => {
      // Simulate element near window edge
      triggerElement.getBoundingClientRect = () => ({
        top: 10,
        left: 10,
        right: 60,
        bottom: 30,
        width: 50,
        height: 20
      });
      
      component.setPosition('top');
      component.show();
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.classList.contains('tooltip-position-bottom')).toBe(true);
    });
  });
  
  describe('Content Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('updates content dynamically', () => {
      component.setContent('New content');
      component.show();
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.textContent).toBe('New content');
    });
    
    it('supports HTML content', () => {
      component.setContent('<strong>Bold content</strong>');
      component.show();
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.innerHTML).toContain('<strong>Bold content</strong>');
    });
  });
  
  describe('Accessibility', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('sets correct ARIA attributes', () => {
      expect(triggerElement.getAttribute('aria-describedby')).toBeDefined();
      
      const tooltipId = triggerElement.getAttribute('aria-describedby');
      const tooltip = document.getElementById(tooltipId);
      expect(tooltip).toBeDefined();
      expect(tooltip.getAttribute('role')).toBe('tooltip');
    });
    
    it('handles keyboard focus', () => {
      fireEvent.focus(triggerElement);
      jest.advanceTimersByTime(200);
      
      const tooltip = document.querySelector('.tooltip');
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(false);
      
      fireEvent.blur(triggerElement);
      expect(tooltip.classList.contains('tooltip-hidden')).toBe(true);
    });
  });
  
  describe('Events', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('emits show event', () => {
      const showHandler = sinon.spy();
      component.on('show', showHandler);
      
      component.show();
      
      expect(showHandler.calledOnce).toBe(true);
    });
    
    it('emits hide event', () => {
      const hideHandler = sinon.spy();
      component.on('hide', hideHandler);
      
      component.show();
      component.hide();
      
      expect(hideHandler.calledOnce).toBe(true);
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