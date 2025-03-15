/**
 * Progress Indicator Component Tests
 * ------------------------
 * Tests for the ProgressIndicator component that provides a step-based progress visualization.
 */

import { ProgressIndicatorComponent } from '../../../assets/js/components/progress_indicator';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('ProgressIndicator Component', () => {
  let testContainer;
  let component;
  
  const mockSteps = [
    { id: 'step1', label: 'Step 1', status: 'complete' },
    { id: 'step2', label: 'Step 2', status: 'current' },
    { id: 'step3', label: 'Step 3', status: 'pending' },
    { id: 'step4', label: 'Step 4', status: 'pending' }
  ];
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the progress indicator element
    const indicatorElement = document.createElement('div');
    indicatorElement.className = 'progress-indicator';
    indicatorElement.setAttribute('data-current-step', 'step2');
    testContainer.appendChild(indicatorElement);
    
    // Initialize the component
    component = new ProgressIndicatorComponent(indicatorElement, { steps: mockSteps });
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
      expect(component.options.steps).toEqual(mockSteps);
      expect(component.getCurrentStep()).toBe('step2');
    });
    
    it('creates step indicators', () => {
      component.initialize();
      
      const steps = document.querySelectorAll('.progress-step');
      expect(steps.length).toBe(4);
      
      const currentStep = document.querySelector('.progress-step.current');
      expect(currentStep.getAttribute('data-step-id')).toBe('step2');
    });
    
    it('creates connecting lines', () => {
      component.initialize();
      
      const connectors = document.querySelectorAll('.step-connector');
      expect(connectors.length).toBe(3); // Number of steps - 1
    });
  });
  
  describe('Step Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('updates step status', () => {
      component.updateStepStatus('step2', 'complete');
      component.updateStepStatus('step3', 'current');
      
      const step2 = document.querySelector('[data-step-id="step2"]');
      expect(step2.classList.contains('complete')).toBe(true);
      
      const step3 = document.querySelector('[data-step-id="step3"]');
      expect(step3.classList.contains('current')).toBe(true);
    });
    
    it('handles step completion', () => {
      component.completeStep('step2');
      
      const step2 = document.querySelector('[data-step-id="step2"]');
      expect(step2.classList.contains('complete')).toBe(true);
      
      const step3 = document.querySelector('[data-step-id="step3"]');
      expect(step3.classList.contains('current')).toBe(true);
    });
    
    it('validates step transitions', () => {
      expect(() => component.updateStepStatus('step4', 'current')).toThrow();
      expect(component.getCurrentStep()).toBe('step2');
    });
  });
  
  describe('Navigation', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('navigates to next step', () => {
      component.nextStep();
      
      expect(component.getCurrentStep()).toBe('step3');
      const step3 = document.querySelector('[data-step-id="step3"]');
      expect(step3.classList.contains('current')).toBe(true);
    });
    
    it('navigates to previous step', () => {
      component.previousStep();
      
      expect(component.getCurrentStep()).toBe('step1');
      const step1 = document.querySelector('[data-step-id="step1"]');
      expect(step1.classList.contains('current')).toBe(true);
    });
    
    it('prevents invalid navigation', () => {
      // Try to go past the last step
      component.nextStep();
      component.nextStep();
      component.nextStep();
      
      expect(component.getCurrentStep()).toBe('step4');
      
      // Try to go before the first step
      component.previousStep();
      component.previousStep();
      component.previousStep();
      component.previousStep();
      
      expect(component.getCurrentStep()).toBe('step1');
    });
  });
  
  describe('Event Handling', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('emits step change events', () => {
      const changeHandler = sinon.spy();
      component.on('stepChange', changeHandler);
      
      component.nextStep();
      
      expect(changeHandler.calledWith({
        previousStep: 'step2',
        currentStep: 'step3'
      })).toBe(true);
    });
    
    it('emits step complete events', () => {
      const completeHandler = sinon.spy();
      component.on('stepComplete', completeHandler);
      
      component.completeStep('step2');
      
      expect(completeHandler.calledWith({
        step: 'step2',
        nextStep: 'step3'
      })).toBe(true);
    });
  });
  
  describe('Dynamic Step Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('adds new step', () => {
      component.addStep({
        id: 'step5',
        label: 'Step 5',
        status: 'pending'
      });
      
      const steps = document.querySelectorAll('.progress-step');
      expect(steps.length).toBe(5);
      expect(steps[4].getAttribute('data-step-id')).toBe('step5');
    });
    
    it('removes step', () => {
      component.removeStep('step4');
      
      const steps = document.querySelectorAll('.progress-step');
      expect(steps.length).toBe(3);
      expect(Array.from(steps).map(step => step.getAttribute('data-step-id')))
        .toEqual(['step1', 'step2', 'step3']);
    });
    
    it('updates step data', () => {
      component.updateStep('step2', {
        label: 'Modified Step',
        description: 'Updated description'
      });
      
      const step2 = document.querySelector('[data-step-id="step2"]');
      expect(step2.querySelector('.step-label').textContent).toBe('Modified Step');
      expect(step2.querySelector('.step-description').textContent).toBe('Updated description');
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