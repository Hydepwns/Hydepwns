/**
 * ProgressIndicatorComponent Tests
 * --------------------------------
 * Tests for the ProgressIndicatorComponent class.
 */

import { ProgressIndicatorComponent } from '../components/progress_indicator';
import EventManager from '../components/event_manager';
import DOMCleanup from '../utils/dom_cleanup';

// Mock dependencies
jest.mock('../components/event_manager', () => ({
  registerComponent: jest.fn().mockReturnValue({
    addEventListener: jest.fn()
  }),
  unregisterComponent: jest.fn()
}));

jest.mock('../utils/dom_cleanup', () => ({
  register: jest.fn().mockReturnValue({
    cleanup: jest.fn(),
    addNode: jest.fn(),
    addCleanupFunction: jest.fn()
  })
}));

describe('ProgressIndicatorComponent', () => {
  let component;
  let container;
  
  // Mock requestAnimationFrame and cancelAnimationFrame
  const originalRequestAnimationFrame = window.requestAnimationFrame;
  const originalCancelAnimationFrame = window.cancelAnimationFrame;
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Mock requestAnimationFrame
    window.requestAnimationFrame = jest.fn(callback => {
      return setTimeout(() => callback(performance.now() + 100), 0);
    });
    
    // Mock cancelAnimationFrame
    window.cancelAnimationFrame = jest.fn(id => {
      clearTimeout(id);
    });
    
    // Mock performance.now
    if (!window.performance) {
      window.performance = {};
    }
    window.performance.now = jest.fn(() => Date.now());
    
    // Mock matchMedia
    window.matchMedia = jest.fn().mockReturnValue({
      matches: false
    });
    
    // Create container element
    container = document.createElement('div');
    document.body.appendChild(container);
    
    // Set up spies
    jest.spyOn(window, 'clearInterval');
    jest.spyOn(window, 'setInterval').mockImplementation(() => 123);
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    document.body.removeChild(container);
    
    // Restore original functions
    window.requestAnimationFrame = originalRequestAnimationFrame;
    window.cancelAnimationFrame = originalCancelAnimationFrame;
    
    // Clear any intervals that might be pending
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });
  
  describe('Spinner Tests', () => {
    beforeEach(() => {
      // Configure container as a spinner
      container.classList.add('spinner');
      
      // Add spinner animation element
      const spinnerElement = document.createElement('span');
      spinnerElement.className = 'spinner-animation';
      spinnerElement.textContent = '⠋';
      container.appendChild(spinnerElement);
    });
    
    test('should initialize spinner with default options', () => {
      component = new ProgressIndicatorComponent({
        container
      });
      
      expect(component.options.defaultSpinnerFrames).toEqual(
        ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
      );
      expect(component.options.defaultSpinnerSpeed).toBe(100);
    });
    
    test('should mount spinner component and register with services', () => {
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
      expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
      expect(component.elements.container).toBe(container);
      expect(component._state.type).toBe('spinner');
    });
    
    test('should set up IntersectionObserver for spinner', () => {
      // Mock IntersectionObserver
      const mockObserve = jest.fn();
      const mockDisconnect = jest.fn();
      
      window.IntersectionObserver = jest.fn(() => ({
        observe: mockObserve,
        disconnect: mockDisconnect
      }));
      
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      expect(window.IntersectionObserver).toHaveBeenCalled();
      expect(mockObserve).toHaveBeenCalledWith(container);
      
      // Check that the cleanup function was registered
      expect(component.cleanup.addCleanupFunction).toHaveBeenCalled();
    });
    
    test('should start spinner animation when visible', () => {
      // Mock IntersectionObserver to trigger visibility
      window.IntersectionObserver = jest.fn(callback => {
        setTimeout(() => {
          callback([{ isIntersecting: true }]);
        }, 0);
        
        return {
          observe: jest.fn(),
          disconnect: jest.fn()
        };
      });
      
      jest.useFakeTimers();
      
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      // Wait for the IntersectionObserver callback
      jest.runAllTimers();
      
      expect(component._state.inViewport).toBe(true);
      expect(window.setInterval).toHaveBeenCalled();
      
      // Clean up timers
      component.destroy();
      expect(window.clearInterval).toHaveBeenCalled();
    });
    
    test('should stop spinner animation when not visible', () => {
      // Mock IntersectionObserver to trigger visibility change
      let observerCallback;
      window.IntersectionObserver = jest.fn(callback => {
        observerCallback = callback;
        return {
          observe: jest.fn(),
          disconnect: jest.fn()
        };
      });
      
      jest.useFakeTimers();
      
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      // First make it visible
      observerCallback([{ isIntersecting: true }]);
      expect(component._state.inViewport).toBe(true);
      
      // Then make it invisible
      observerCallback([{ isIntersecting: false }]);
      expect(component._state.inViewport).toBe(false);
      expect(window.clearInterval).toHaveBeenCalled();
    });
    
    test('should allow manually starting and stopping spinner', () => {
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      // Make it visible first
      component._state.inViewport = true;
      
      // Start spinner manually
      component.startSpinner();
      expect(window.setInterval).toHaveBeenCalled();
      
      // Stop spinner manually
      component.stopSpinner();
      expect(window.clearInterval).toHaveBeenCalled();
    });
  });
  
  describe('Progress Bar Tests', () => {
    beforeEach(() => {
      // Configure container as a linear progress bar
      container.classList.add('linear');
      container.classList.add('animate');
      
      // Add progress bar element
      const progressBar = document.createElement('div');
      progressBar.className = 'progress-bar';
      progressBar.setAttribute('role', 'progressbar');
      progressBar.setAttribute('aria-valuenow', '0');
      progressBar.setAttribute('aria-valuemin', '0');
      progressBar.setAttribute('aria-valuemax', '100');
      progressBar.textContent = '[-----] 0%';
      container.appendChild(progressBar);
      
      // Enable animation frame mocking
      jest.useFakeTimers();
    });
    
    test('should initialize progress bar component', () => {
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      expect(component._state.type).toBe('linear');
      expect(component.elements.progressBarElement).toBeTruthy();
    });
    
    test('should update progress bar value without animation when not visible', () => {
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      // Progress bar starts as not visible
      expect(component._state.inViewport).toBe(false);
      
      // Update progress
      component.updateProgress(50, 100);
      
      // Check that the aria attributes were updated
      const progressBar = container.querySelector('[role="progressbar"]');
      expect(progressBar.getAttribute('aria-valuenow')).toBe('50');
      
      // Check that the text was updated
      expect(progressBar.textContent).toContain('50%');
    });
    
    test('should animate progress bar when visible', () => {
      // Make progress bar visible via IntersectionObserver
      window.IntersectionObserver = jest.fn(callback => {
        setTimeout(() => {
          callback([{ isIntersecting: true }]);
        }, 0);
        
        return {
          observe: jest.fn(),
          disconnect: jest.fn()
        };
      });
      
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      // Run the timer to make the component visible
      jest.runAllTimers();
      expect(component._state.inViewport).toBe(true);
      
      // Update progress
      component.updateProgress(75, 100);
      
      // Should use requestAnimationFrame for animation
      expect(window.requestAnimationFrame).toHaveBeenCalled();
      
      // Run the animation timer
      jest.runAllTimers();
      
      // Check that the progress bar was updated
      const progressBar = container.querySelector('[role="progressbar"]');
      expect(progressBar.getAttribute('aria-valuenow')).toBe('75');
      expect(progressBar.textContent).toContain('75%');
    });
    
    test('should cancel running animations when a new update arrives', () => {
      // Make component visible
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      component._state.inViewport = true;
      
      // Start an animation
      component._animateProgressBar(0, 50, 100);
      expect(window.requestAnimationFrame).toHaveBeenCalled();
      
      // Start a new animation before the first completes
      component._animateProgressBar(50, 75, 100);
      expect(window.cancelAnimationFrame).toHaveBeenCalled();
    });
    
    test('should dispatch custom event on progress update', () => {
      component = new ProgressIndicatorComponent({
        container
      }).mount();
      
      // Mock dispatchEvent
      container.dispatchEvent = jest.fn();
      
      // Update progress
      component.updateProgress(25, 100);
      
      // Check that event was dispatched
      expect(container.dispatchEvent).toHaveBeenCalled();
      expect(container.dispatchEvent.mock.calls[0][0].type).toBe('progressUpdate');
      expect(container.dispatchEvent.mock.calls[0][0].detail).toEqual({
        componentId: component.componentId,
        value: 25,
        maxValue: 100,
        percentage: 25
      });
    });
  });
  
  test('should respect prefers-reduced-motion setting', () => {
    // Mock matchMedia to simulate reduced motion preference
    window.matchMedia = jest.fn().mockReturnValue({
      matches: true
    });
    
    component = new ProgressIndicatorComponent({
      container
    }).mount();
    
    expect(component._state.animationAllowed).toBe(false);
  });
  
  test('should properly clean up resources when destroyed', () => {
    // Mock IntersectionObserver
    window.IntersectionObserver = jest.fn(() => ({
      observe: jest.fn(),
      disconnect: jest.fn()
    }));
    
    component = new ProgressIndicatorComponent({
      container
    }).mount();
    
    // Set up animations to be cleared
    component.spinnerInterval = setInterval(() => {}, 100);
    component.progressAnimation = 123;
    
    // Destroy component
    component.destroy();
    
    // Check that animations were stopped
    expect(window.clearInterval).toHaveBeenCalled();
    expect(window.cancelAnimationFrame).toHaveBeenCalled();
    
    // Check that cleanup was called
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
    
    // Check that resources were cleared
    expect(component.elements).toEqual({});
    expect(component._state).toEqual({});
  });
}); 