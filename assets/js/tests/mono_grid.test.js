/**
 * MonoGridComponent Tests
 * -----------------------
 * Tests for the MonoGridComponent class.
 */

import { MonoGridComponent } from '../components/mono_grid';
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
    addNode: jest.fn()
  })
}));

describe('MonoGridComponent', () => {
  let component;
  let container;
  
  // Mock element creation and style property access
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Create mock container
    container = document.createElement('div');
    container.dataset.cols = '80';
    container.classList.add('mono-grid');
    
    // Mock getComputedStyle
    window.getComputedStyle = jest.fn().mockReturnValue({
      getPropertyValue: jest.fn((prop) => {
        if (prop === '--mono-grid-cols') return '80';
        if (prop === '--mono-grid-cell-width') return '1ch';
        if (prop === '--mono-grid-cell-height') return '1.5rem';
        return '';
      })
    });
    
    // Append to document body for testing
    document.body.appendChild(container);
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    document.body.removeChild(container);
  });
  
  test('should initialize with default options', () => {
    component = new MonoGridComponent({
      container
    });
    
    expect(component.options.cols).toBe(80);
    expect(component.options.cellWidth).toBe('1ch');
    expect(component.options.cellHeight).toBe('1.5rem');
  });
  
  test('should mount component and register with EventManager and DOMCleanup', () => {
    component = new MonoGridComponent({
      container
    }).mount();
    
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    expect(component.elements.container).toBe(container);
  });
  
  test('should set up grid with correct dimensions', () => {
    component = new MonoGridComponent({
      container,
      cols: 100,
      cellWidth: '0.8ch',
      cellHeight: '1.2rem'
    }).mount();
    
    // Should use values from options since they override defaults
    expect(component._state.originalCols).toBe(100);
    
    // Verify style properties were set
    expect(container.style.getPropertyValue('--mono-grid-cols')).toBe('100');
    expect(container.style.getPropertyValue('--mono-grid-cell-width')).toBe('0.8ch');
    expect(container.style.getPropertyValue('--mono-grid-cell-height')).toBe('1.2rem');
  });
  
  test('should set up debug mode when container has debug class', () => {
    container.classList.add('mono-grid--debug');
    
    component = new MonoGridComponent({
      container
    }).mount();
    
    expect(component._state.isDebugMode).toBe(true);
    expect(component.elements.debugToggle).toBeTruthy();
    expect(component.elements.debugToggle.tagName).toBe('BUTTON');
    expect(component.elements.debugToggle.className).toBe('mono-grid-debug-toggle');
  });
  
  test('should toggle debug grid visualization', () => {
    container.classList.add('mono-grid--debug');
    
    // Add some cell and row elements
    const cell = document.createElement('div');
    cell.classList.add('mono-grid-cell');
    container.appendChild(cell);
    
    const row = document.createElement('div');
    row.classList.add('mono-grid-row');
    container.appendChild(row);
    
    component = new MonoGridComponent({
      container
    }).mount();
    
    // Toggle debug grid
    component.toggleDebugGrid();
    
    // Check that classes were toggled
    expect(container.classList.contains('mono-grid--debug-lines')).toBe(true);
    expect(cell.classList.contains('mono-grid-cell--debug')).toBe(true);
    expect(row.classList.contains('mono-grid-row--debug')).toBe(true);
    
    // Toggle again
    component.toggleDebugGrid();
    
    // Check that classes were removed
    expect(container.classList.contains('mono-grid--debug-lines')).toBe(false);
    expect(cell.classList.contains('mono-grid-cell--debug')).toBe(false);
    expect(row.classList.contains('mono-grid-row--debug')).toBe(false);
  });
  
  test('should set up keyboard navigation for focusable cells', () => {
    // Create some focusable cells
    for (let i = 0; i < 9; i++) {
      const cell = document.createElement('div');
      cell.classList.add('mono-grid-cell');
      cell.setAttribute('tabindex', '0');
      container.appendChild(cell);
    }
    
    component = new MonoGridComponent({
      container
    }).mount();
    
    // Verify that focusable cells were found
    expect(component.elements.focusableCells.length).toBe(9);
    
    // Get event handler setup
    const events = EventManager.registerComponent.mock.results[0].value;
    expect(events.addEventListener).toHaveBeenCalledTimes(10); // 9 cells + 1 window resize
  });
  
  test('should handle grid navigation with keyboard', () => {
    // Create a 3x3 grid of focusable cells
    const cells = [];
    for (let i = 0; i < 9; i++) {
      const cell = document.createElement('div');
      cell.classList.add('mono-grid-cell');
      cell.setAttribute('tabindex', '0');
      container.appendChild(cell);
      cells.push(cell);
    }
    
    // Mock container style for getting column count
    container.style.getPropertyValue = jest.fn((prop) => {
      if (prop === '--mono-grid-cols') return '3';
      return '';
    });
    
    // Mock focus method on cells
    cells.forEach(cell => {
      cell.focus = jest.fn();
    });
    
    // Create a spy for dispatchEvent
    container.dispatchEvent = jest.fn();
    
    component = new MonoGridComponent({
      container,
      cols: 3
    }).mount();
    
    // Test navigation in different directions
    
    // Navigate right
    component._navigateGrid(cells[0], 'ArrowRight');
    expect(cells[1].focus).toHaveBeenCalled();
    
    // Navigate down
    component._navigateGrid(cells[0], 'ArrowDown');
    expect(cells[3].focus).toHaveBeenCalled();
    
    // Navigate left
    component._navigateGrid(cells[1], 'ArrowLeft');
    expect(cells[0].focus).toHaveBeenCalled();
    
    // Navigate up
    component._navigateGrid(cells[3], 'ArrowUp');
    expect(cells[0].focus).toHaveBeenCalled();
    
    // Verify custom event was dispatched
    expect(container.dispatchEvent).toHaveBeenCalled();
    expect(container.dispatchEvent.mock.calls[0][0].type).toBe('monoGridNavigation');
  });
  
  test('should handle resize and apply responsive adjustments', () => {
    // Create spy for clearTimeout
    jest.useFakeTimers();
    jest.spyOn(global, 'clearTimeout');
    
    component = new MonoGridComponent({
      container,
      cols: 80
    }).mount();
    
    // Store original state
    component._state.originalCols = 80;
    
    // Test small screen adjustment
    window.innerWidth = 400;
    component._handleResize();
    jest.runAllTimers();
    
    expect(container.style.getPropertyValue('--mono-grid-cols')).toBe('40');
    
    // Test medium screen adjustment
    window.innerWidth = 700;
    component._handleResize();
    jest.runAllTimers();
    
    expect(container.style.getPropertyValue('--mono-grid-cols')).toBe('60');
    
    // Test large screen reset
    window.innerWidth = 1000;
    component._handleResize();
    jest.runAllTimers();
    
    expect(container.style.getPropertyValue('--mono-grid-cols')).toBe('80');
    
    // Verify that resize event was dispatched
    expect(container.dispatchEvent).toHaveBeenCalled();
    expect(container.dispatchEvent.mock.calls[0][0].type).toBe('monoGridResize');
  });
  
  test('should properly clean up resources when destroyed', () => {
    component = new MonoGridComponent({
      container
    }).mount();
    
    // Set a timeout to verify it gets cleared
    component.resizeTimeout = setTimeout(() => {}, 1000);
    
    // Destroy component
    component.destroy();
    
    // Verify cleanup was called
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
    
    // Verify state and elements were cleared
    expect(component.elements).toEqual({});
    expect(component._state).toEqual({});
  });
}); 