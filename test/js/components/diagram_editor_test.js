/**
 * Diagram Editor Component Tests
 * ------------------------
 * Tests for the DiagramEditor component that provides diagram creation and editing functionality.
 */

import { DiagramEditorComponent } from '../../../assets/js/components/diagram_editor';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('DiagramEditor Component', () => {
  let testContainer;
  let component;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the diagram editor element
    const editorElement = document.createElement('div');
    editorElement.className = 'diagram-editor';
    editorElement.setAttribute('data-canvas-width', '800');
    editorElement.setAttribute('data-canvas-height', '600');
    testContainer.appendChild(editorElement);
    
    // Initialize the component
    component = new DiagramEditorComponent(editorElement);
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
      expect(component.options.canvasWidth).toBe(800);
      expect(component.options.canvasHeight).toBe(600);
    });
    
    it('creates the canvas with correct dimensions', () => {
      component.initialize();
      
      const canvas = document.querySelector('.diagram-canvas');
      expect(canvas).toBeDefined();
      expect(canvas.width).toBe(800);
      expect(canvas.height).toBe(600);
    });
    
    it('sets default options when not provided', () => {
      const defaultElement = document.createElement('div');
      defaultElement.className = 'diagram-editor';
      testContainer.appendChild(defaultElement);
      
      const defaultComponent = new DiagramEditorComponent(defaultElement);
      
      expect(defaultComponent.options.canvasWidth).toBe(1024); // Default value
      expect(defaultComponent.options.canvasHeight).toBe(768); // Default value
      
      defaultComponent.destroy();
    });
  });
  
  describe('Drawing Operations', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('creates shapes on canvas', () => {
      const shape = component.createShape({
        type: 'rectangle',
        x: 100,
        y: 100,
        width: 50,
        height: 50
      });
      
      expect(shape).toBeDefined();
      expect(shape.type).toBe('rectangle');
      expect(component.getShapes().length).toBe(1);
    });
    
    it('deletes shapes from canvas', () => {
      const shape = component.createShape({
        type: 'rectangle',
        x: 100,
        y: 100,
        width: 50,
        height: 50
      });
      
      component.deleteShape(shape.id);
      expect(component.getShapes().length).toBe(0);
    });
    
    it('handles shape selection', () => {
      const shape = component.createShape({
        type: 'rectangle',
        x: 100,
        y: 100,
        width: 50,
        height: 50
      });
      
      component.selectShape(shape.id);
      expect(component.getSelectedShape()).toBe(shape);
    });
  });
  
  describe('Undo/Redo Operations', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles undo operation', () => {
      const shape = component.createShape({
        type: 'rectangle',
        x: 100,
        y: 100,
        width: 50,
        height: 50
      });
      
      component.undo();
      expect(component.getShapes().length).toBe(0);
    });
    
    it('handles redo operation', () => {
      const shape = component.createShape({
        type: 'rectangle',
        x: 100,
        y: 100,
        width: 50,
        height: 50
      });
      
      component.undo();
      component.redo();
      expect(component.getShapes().length).toBe(1);
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