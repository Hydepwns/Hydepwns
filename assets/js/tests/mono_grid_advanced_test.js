/**
 * Advanced MonoGrid Component Tests
 * -------------------------------
 * Additional test coverage for advanced features, edge cases,
 * and complex interactions in the MonoGrid component.
 */

import { MonoGridComponent } from '../components/mono_grid';
import EventManager from '../components/event_manager';
import DOMCleanup from '../utils/dom_cleanup';

// Mock dependencies
jest.mock('../components/event_manager', () => ({
  registerComponent: jest.fn().mockReturnValue({
    addEventListener: jest.fn(),
    addDelegatedEventListener: jest.fn()
  }),
  unregisterComponent: jest.fn()
}));

jest.mock('../utils/dom_cleanup', () => ({
  register: jest.fn().mockReturnValue({
    cleanup: jest.fn(),
    addNode: jest.fn()
  })
}));

describe('MonoGridComponent - Advanced Features', () => {
  let component;
  let container;
  let mockLiveViewHook;
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Create test container
    container = document.createElement('div');
    container.className = 'mono-grid';
    document.body.appendChild(container);
    
    // Mock LiveView hook
    mockLiveViewHook = {
      el: container,
      pushEvent: jest.fn()
    };
    
    // Create component instance
    component = new MonoGridComponent({
      container,
      liveViewHook: mockLiveViewHook,
      debug: true
    });
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    container = null;
    component = null;
  });

  describe('Responsive Behavior', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should handle window resize events', () => {
      // Mock window resize
      const resizeEvent = new Event('resize');
      window.dispatchEvent(resizeEvent);
      
      // Should have registered resize handler
      const events = EventManager.registerComponent.mock.results[0].value;
      expect(events.addEventListener).toHaveBeenCalledWith(
        window,
        'resize',
        expect.any(Function)
      );
    });
    
    test('should debounce resize handler', () => {
      jest.useFakeTimers();
      
      // Trigger multiple resize events
      for (let i = 0; i < 5; i++) {
        window.dispatchEvent(new Event('resize'));
      }
      
      // Fast-forward timers
      jest.runAllTimers();
      
      // Should have cleared previous timeout
      expect(clearTimeout).toHaveBeenCalledTimes(4);
      
      jest.useRealTimers();
    });
    
    test('should reset to default grid on large screens', () => {
      // Mock large screen
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 1920
      });
      
      // Trigger resize
      window.dispatchEvent(new Event('resize'));
      
      // Should reset to original columns
      expect(container.style.getPropertyValue('--mono-grid-cols'))
        .toBe(component._state.originalCols.toString());
    });
  });

  describe('Keyboard Navigation', () => {
    beforeEach(() => {
      // Create grid cells
      for (let i = 0; i < 9; i++) {
        const cell = document.createElement('div');
        cell.className = 'mono-grid-cell';
        cell.setAttribute('tabindex', '0');
        container.appendChild(cell);
      }
      
      component.mount();
    });
    
    test('should navigate right between cells', () => {
      const cells = component.elements.focusableCells;
      cells[0].focus();
      
      // Simulate right arrow key
      cells[0].dispatchEvent(new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        bubbles: true
      }));
      
      expect(document.activeElement).toBe(cells[1]);
    });
    
    test('should navigate down between cells', () => {
      const cells = component.elements.focusableCells;
      cells[0].focus();
      
      // Simulate down arrow key
      cells[0].dispatchEvent(new KeyboardEvent('keydown', {
        key: 'ArrowDown',
        bubbles: true
      }));
      
      // Should move to cell below (assuming 3x3 grid)
      expect(document.activeElement).toBe(cells[3]);
    });
    
    test('should not navigate beyond grid boundaries', () => {
      const cells = component.elements.focusableCells;
      cells[8].focus(); // Last cell
      
      // Try to navigate right
      cells[8].dispatchEvent(new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        bubbles: true
      }));
      
      // Should stay on last cell
      expect(document.activeElement).toBe(cells[8]);
    });
    
    test('should dispatch navigation events', () => {
      const cells = component.elements.focusableCells;
      cells[0].focus();
      
      // Create spy for custom event
      const eventSpy = jest.fn();
      container.addEventListener('monoGridNavigation', eventSpy);
      
      // Navigate right
      cells[0].dispatchEvent(new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        bubbles: true
      }));
      
      expect(eventSpy).toHaveBeenCalled();
      expect(eventSpy.mock.calls[0][0].detail).toEqual({
        componentId: component.componentId,
        direction: 'ArrowRight',
        fromIndex: 0,
        toIndex: 1,
        fromCell: cells[0],
        toCell: cells[1]
      });
    });
  });

  describe('Debug Mode', () => {
    beforeEach(() => {
      container.classList.add('mono-grid--debug');
      component.mount();
    });
    
    test('should update debug info on resize', () => {
      // Mock element dimensions
      Object.defineProperty(container, 'clientWidth', {
        value: 800,
        configurable: true
      });
      Object.defineProperty(container, 'clientHeight', {
        value: 600,
        configurable: true
      });
      
      // Mock font size
      window.getComputedStyle = jest.fn().mockReturnValue({
        fontSize: '16px',
        getPropertyValue: jest.fn((prop) => {
          if (prop === '--mono-grid-cols') return '80';
          if (prop === '--mono-grid-cell-height') return '1.5rem';
          return '';
        })
      });
      
      component._updateDebugInfo();
      
      expect(container.dataset.debugInfo).toMatch(/80×\d+ grid | 50 chars wide/);
    });
    
    test('should toggle debug grid visualization', () => {
      // Add some test cells and rows
      const cell = document.createElement('div');
      cell.className = 'mono-grid-cell';
      container.appendChild(cell);
      
      const row = document.createElement('div');
      row.className = 'mono-grid-row';
      container.appendChild(row);
      
      // Toggle debug mode
      component.toggleDebugGrid();
      
      expect(container.classList.contains('mono-grid--debug-lines')).toBe(true);
      expect(cell.classList.contains('mono-grid-cell--debug')).toBe(true);
      expect(row.classList.contains('mono-grid-row--debug')).toBe(true);
      
      // Toggle again
      component.toggleDebugGrid();
      
      expect(container.classList.contains('mono-grid--debug-lines')).toBe(false);
      expect(cell.classList.contains('mono-grid-cell--debug')).toBe(false);
      expect(row.classList.contains('mono-grid-row--debug')).toBe(false);
    });
  });

  describe('Edge Cases', () => {
    test('should handle rapid mount/unmount cycles', () => {
      for (let i = 0; i < 100; i++) {
        component.mount();
        component.destroy();
      }
      
      // Should not throw errors and cleanup properly
      expect(EventManager.unregisterComponent).toHaveBeenCalledTimes(100);
    });
    
    test('should handle missing LiveView hook', () => {
      component = new MonoGridComponent({
        container,
        debug: true
      }).mount();
      
      // Should still initialize without errors
      expect(component.options.liveViewHook).toBeNull();
      expect(component.elements.container).toBe(container);
    });
    
    test('should handle invalid grid dimensions', () => {
      // Set invalid dimensions
      container.dataset.cols = 'invalid';
      container.dataset.cellWidth = 'invalid';
      container.dataset.cellHeight = 'invalid';
      
      component.mount();
      
      // Should fall back to defaults
      expect(container.style.getPropertyValue('--mono-grid-cols')).toBe('80');
      expect(container.style.getPropertyValue('--mono-grid-cell-width')).toBe('1ch');
      expect(container.style.getPropertyValue('--mono-grid-cell-height')).toBe('1.5rem');
    });
    
    test('should handle removed elements during lifecycle', () => {
      component.mount();
      
      // Remove container during operation
      container.remove();
      
      // These operations should not throw errors
      component._updateDebugInfo();
      component.toggleDebugGrid();
      component.destroy();
    });
  });

  describe('Performance', () => {
    test('should handle large number of cells', () => {
      // Create 1000 cells
      for (let i = 0; i < 1000; i++) {
        const cell = document.createElement('div');
        cell.className = 'mono-grid-cell';
        cell.setAttribute('tabindex', '0');
        container.appendChild(cell);
      }
      
      const startTime = performance.now();
      component.mount();
      const endTime = performance.now();
      
      // Should initialize within reasonable time (e.g., 100ms)
      expect(endTime - startTime).toBeLessThan(100);
      
      // Should have registered all cells
      expect(component.elements.focusableCells.length).toBe(1000);
    });
    
    test('should handle rapid grid toggles', () => {
      component.mount();
      
      const startTime = performance.now();
      
      // Toggle grid 100 times
      for (let i = 0; i < 100; i++) {
        component.toggleDebugGrid();
      }
      
      const endTime = performance.now();
      
      // Should complete within reasonable time (e.g., 50ms)
      expect(endTime - startTime).toBeLessThan(50);
    });
  });
}); 