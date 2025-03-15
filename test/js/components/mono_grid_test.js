/**
 * Mono Grid Component Tests
 * ------------------------
 * Tests for the MonoGrid component that provides a monospaced grid layout system.
 */

import { MonoGridComponent } from '../../../assets/js/components/mono_grid';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('MonoGrid Component', () => {
  let testContainer;
  let component;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the mono grid element
    const gridElement = document.createElement('div');
    gridElement.className = 'mono-grid';
    gridElement.setAttribute('data-columns', '80');
    gridElement.setAttribute('data-rows', '24');
    gridElement.setAttribute('data-cell-size', '16');
    testContainer.appendChild(gridElement);
    
    // Initialize the component
    component = new MonoGridComponent(gridElement);
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
      expect(component.options.columns).toBe(80);
      expect(component.options.rows).toBe(24);
      expect(component.options.cellSize).toBe(16);
    });
    
    it('creates grid with correct dimensions', () => {
      component.initialize();
      
      const cells = document.querySelectorAll('.mono-grid-cell');
      expect(cells.length).toBe(80 * 24);
      
      const firstCell = cells[0];
      expect(firstCell.style.width).toBe('16px');
      expect(firstCell.style.height).toBe('16px');
    });
    
    it('sets default options when not provided', () => {
      const defaultElement = document.createElement('div');
      defaultElement.className = 'mono-grid';
      testContainer.appendChild(defaultElement);
      
      const defaultComponent = new MonoGridComponent(defaultElement);
      
      expect(defaultComponent.options.columns).toBe(80); // Default value
      expect(defaultComponent.options.rows).toBe(24); // Default value
      expect(defaultComponent.options.cellSize).toBe(16); // Default value
      
      defaultComponent.destroy();
    });
  });
  
  describe('Grid Operations', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles cell selection', () => {
      const cell = document.querySelector('.mono-grid-cell');
      fireEvent.click(cell);
      
      expect(cell.classList.contains('selected')).toBe(true);
    });
    
    it('handles cell deselection', () => {
      const cell = document.querySelector('.mono-grid-cell');
      fireEvent.click(cell);
      fireEvent.click(cell);
      
      expect(cell.classList.contains('selected')).toBe(false);
    });
    
    it('maintains monospace alignment', () => {
      const cells = document.querySelectorAll('.mono-grid-cell');
      const firstCell = cells[0];
      const secondCell = cells[1];
      
      expect(firstCell.offsetLeft % 16).toBe(0);
      expect(secondCell.offsetLeft - firstCell.offsetLeft).toBe(16);
    });
  });
  
  describe('Grid Resizing', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles grid resize', () => {
      component.resize(40, 12);
      
      const cells = document.querySelectorAll('.mono-grid-cell');
      expect(cells.length).toBe(40 * 12);
    });
    
    it('maintains cell size after resize', () => {
      component.resize(40, 12);
      
      const cell = document.querySelector('.mono-grid-cell');
      expect(cell.style.width).toBe('16px');
      expect(cell.style.height).toBe('16px');
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