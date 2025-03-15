/**
 * Terminal Component Tests
 * ------------------------
 * Tests for the Terminal component that provides a terminal emulator interface.
 */

import { TerminalComponent } from '../../../assets/js/components/terminal';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('Terminal Component', () => {
  let testContainer;
  let component;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the terminal element
    const terminalElement = document.createElement('div');
    terminalElement.className = 'terminal';
    terminalElement.setAttribute('data-theme', 'dark');
    terminalElement.setAttribute('data-font-size', '14');
    testContainer.appendChild(terminalElement);
    
    // Initialize the component
    component = new TerminalComponent(terminalElement);
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
      expect(component.options.theme).toBe('dark');
      expect(component.options.fontSize).toBe(14);
    });
    
    it('creates terminal structure', () => {
      component.initialize();
      
      const output = document.querySelector('.terminal-output');
      expect(output).toBeDefined();
      
      const input = document.querySelector('.terminal-input');
      expect(input).toBeDefined();
      expect(input.getAttribute('contenteditable')).toBe('true');
    });
    
    it('sets default options when not provided', () => {
      const defaultElement = document.createElement('div');
      defaultElement.className = 'terminal';
      testContainer.appendChild(defaultElement);
      
      const defaultComponent = new TerminalComponent(defaultElement);
      
      expect(defaultComponent.options.theme).toBe('dark');
      expect(defaultComponent.options.fontSize).toBe(14);
      expect(defaultComponent.options.maxHistory).toBe(1000);
      
      defaultComponent.destroy();
    });
  });
  
  describe('Input Handling', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles command input', () => {
      const input = document.querySelector('.terminal-input');
      input.textContent = 'echo test';
      
      fireEvent.keyDown(input, { key: 'Enter' });
      
      const output = document.querySelector('.terminal-output');
      expect(output.textContent).toContain('test');
    });
    
    it('maintains command history', () => {
      const input = document.querySelector('.terminal-input');
      
      input.textContent = 'command1';
      fireEvent.keyDown(input, { key: 'Enter' });
      
      input.textContent = 'command2';
      fireEvent.keyDown(input, { key: 'Enter' });
      
      // Navigate history
      fireEvent.keyDown(input, { key: 'ArrowUp' });
      expect(input.textContent).toBe('command2');
      
      fireEvent.keyDown(input, { key: 'ArrowUp' });
      expect(input.textContent).toBe('command1');
    });
    
    it('handles command completion', () => {
      const input = document.querySelector('.terminal-input');
      input.textContent = 'ec';
      
      fireEvent.keyDown(input, { key: 'Tab' });
      expect(input.textContent).toBe('echo');
    });
  });
  
  describe('Output Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('writes output to terminal', () => {
      component.write('Test output');
      
      const output = document.querySelector('.terminal-output');
      expect(output.textContent).toContain('Test output');
    });
    
    it('handles ANSI color codes', () => {
      component.write('\x1b[32mGreen text\x1b[0m');
      
      const output = document.querySelector('.terminal-output span');
      expect(output.style.color).toBe('rgb(0, 255, 0)');
    });
    
    it('limits output history', () => {
      // Fill history
      for (let i = 0; i < 1100; i++) {
        component.write(`Line ${i}`);
      }
      
      const lines = document.querySelectorAll('.terminal-output div');
      expect(lines.length).toBeLessThanOrEqual(1000);
    });
  });
  
  describe('Theme Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('switches themes', () => {
      component.setTheme('light');
      
      const terminal = document.querySelector('.terminal');
      expect(terminal.classList.contains('theme-light')).toBe(true);
      expect(terminal.classList.contains('theme-dark')).toBe(false);
    });
    
    it('updates font size', () => {
      component.setFontSize(16);
      
      const terminal = document.querySelector('.terminal');
      expect(terminal.style.fontSize).toBe('16px');
    });
  });
  
  describe('Command Processing', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('executes built-in commands', () => {
      const output = sinon.spy(component, 'write');
      
      component.executeCommand('clear');
      expect(document.querySelector('.terminal-output').textContent).toBe('');
      
      component.executeCommand('help');
      expect(output.calledWith(sinon.match(/Available commands/))).toBe(true);
    });
    
    it('handles custom commands', () => {
      const customCommand = sinon.spy();
      component.registerCommand('test', customCommand);
      
      component.executeCommand('test arg1 arg2');
      expect(customCommand.calledWith(['arg1', 'arg2'])).toBe(true);
    });
    
    it('handles command errors', () => {
      component.executeCommand('invalid-command');
      
      const output = document.querySelector('.terminal-output');
      expect(output.textContent).toContain('Command not found');
    });
  });
  
  describe('Clipboard Operations', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('copies selected text', () => {
      const mockClipboard = {
        writeText: sinon.spy()
      };
      global.navigator.clipboard = mockClipboard;
      
      const output = document.querySelector('.terminal-output');
      output.textContent = 'Test text';
      
      // Simulate text selection
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(output);
      selection.removeAllRanges();
      selection.addRange(range);
      
      fireEvent.keyDown(document, { key: 'c', ctrlKey: true });
      
      expect(mockClipboard.writeText.calledWith('Test text')).toBe(true);
    });
    
    it('pastes text at cursor position', async () => {
      const mockClipboard = {
        readText: sinon.stub().resolves('Pasted text')
      };
      global.navigator.clipboard = mockClipboard;
      
      const input = document.querySelector('.terminal-input');
      
      fireEvent.keyDown(input, { key: 'v', ctrlKey: true });
      
      await new Promise(resolve => setTimeout(resolve, 0));
      expect(input.textContent).toBe('Pasted text');
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