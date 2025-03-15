/**
 * Progress Bar Component Tests
 * ------------------------
 * Tests for the ProgressBar component that provides a visual progress indicator.
 */

import { ProgressBarComponent } from '../../../assets/js/components/progress_bar';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('ProgressBar Component', () => {
  let testContainer;
  let component;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the progress bar element
    const progressElement = document.createElement('div');
    progressElement.className = 'progress-bar';
    progressElement.setAttribute('data-value', '0');
    progressElement.setAttribute('data-max', '100');
    progressElement.setAttribute('data-show-label', 'true');
    testContainer.appendChild(progressElement);
    
    // Initialize the component
    component = new ProgressBarComponent(progressElement);
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
      expect(component.options.value).toBe(0);
      expect(component.options.max).toBe(100);
      expect(component.options.showLabel).toBe(true);
    });
    
    it('creates progress bar structure', () => {
      component.initialize();
      
      const bar = document.querySelector('.progress-bar-fill');
      expect(bar).toBeDefined();
      expect(bar.style.width).toBe('0%');
      
      const label = document.querySelector('.progress-bar-label');
      expect(label).toBeDefined();
      expect(label.textContent).toBe('0%');
    });
    
    it('sets default options when not provided', () => {
      const defaultElement = document.createElement('div');
      defaultElement.className = 'progress-bar';
      testContainer.appendChild(defaultElement);
      
      const defaultComponent = new ProgressBarComponent(defaultElement);
      
      expect(defaultComponent.options.value).toBe(0);
      expect(defaultComponent.options.max).toBe(100);
      expect(defaultComponent.options.showLabel).toBe(false);
      
      defaultComponent.destroy();
    });
  });
  
  describe('Progress Operations', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('updates progress value', () => {
      component.setValue(50);
      
      const bar = document.querySelector('.progress-bar-fill');
      expect(bar.style.width).toBe('50%');
      
      const label = document.querySelector('.progress-bar-label');
      expect(label.textContent).toBe('50%');
    });
    
    it('clamps progress value to valid range', () => {
      component.setValue(-10);
      expect(component.getValue()).toBe(0);
      
      component.setValue(150);
      expect(component.getValue()).toBe(100);
    });
    
    it('handles decimal values', () => {
      component.setValue(33.33);
      
      const bar = document.querySelector('.progress-bar-fill');
      expect(bar.style.width).toBe('33.33%');
      
      const label = document.querySelector('.progress-bar-label');
      expect(label.textContent).toBe('33.33%');
    });
  });
  
  describe('Animation', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('animates progress changes', (done) => {
      const startWidth = document.querySelector('.progress-bar-fill').style.width;
      
      component.setValueWithAnimation(50, 500);
      
      setTimeout(() => {
        const endWidth = document.querySelector('.progress-bar-fill').style.width;
        expect(endWidth).toBe('50%');
        expect(endWidth).not.toBe(startWidth);
        done();
      }, 600);
    });
    
    it('handles multiple animation requests', (done) => {
      component.setValueWithAnimation(50, 200);
      component.setValueWithAnimation(75, 200);
      
      setTimeout(() => {
        const width = document.querySelector('.progress-bar-fill').style.width;
        expect(width).toBe('75%');
        done();
      }, 400);
    });
  });
  
  describe('Label Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('toggles label visibility', () => {
      component.setShowLabel(false);
      
      const label = document.querySelector('.progress-bar-label');
      expect(label.style.display).toBe('none');
      
      component.setShowLabel(true);
      expect(label.style.display).toBe('block');
    });
    
    it('updates label format', () => {
      component.setLabelFormat('Loading: {value}/{max}');
      component.setValue(50);
      
      const label = document.querySelector('.progress-bar-label');
      expect(label.textContent).toBe('Loading: 50/100');
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