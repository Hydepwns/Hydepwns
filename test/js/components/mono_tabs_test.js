/**
 * Mono Tabs Component Tests
 * ------------------------
 * Tests for the MonoTabs component that provides a monospaced tabbed interface.
 */

import { MonoTabsComponent } from '../../../assets/js/components/mono_tabs';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('MonoTabs Component', () => {
  let testContainer;
  let component;
  
  const mockTabs = [
    { id: 'tab1', label: 'Tab 1', content: 'Content 1' },
    { id: 'tab2', label: 'Tab 2', content: 'Content 2' },
    { id: 'tab3', label: 'Tab 3', content: 'Content 3' }
  ];
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the mono tabs element
    const tabsElement = document.createElement('div');
    tabsElement.className = 'mono-tabs';
    tabsElement.setAttribute('data-active-tab', 'tab1');
    testContainer.appendChild(tabsElement);
    
    // Initialize the component
    component = new MonoTabsComponent(tabsElement, { tabs: mockTabs });
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
      expect(component.options.tabs).toEqual(mockTabs);
      expect(component.getActiveTab()).toBe('tab1');
    });
    
    it('creates tab elements', () => {
      component.initialize();
      
      const tabElements = document.querySelectorAll('.mono-tab');
      expect(tabElements.length).toBe(3);
      
      const firstTab = tabElements[0];
      expect(firstTab.textContent).toBe('Tab 1');
      expect(firstTab.classList.contains('active')).toBe(true);
    });
    
    it('creates content panels', () => {
      component.initialize();
      
      const contentPanels = document.querySelectorAll('.tab-content');
      expect(contentPanels.length).toBe(3);
      
      const activePanel = document.querySelector('.tab-content.active');
      expect(activePanel.textContent).toBe('Content 1');
    });
  });
  
  describe('Tab Operations', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('switches tabs on click', () => {
      const secondTab = document.querySelectorAll('.mono-tab')[1];
      fireEvent.click(secondTab);
      
      expect(secondTab.classList.contains('active')).toBe(true);
      expect(component.getActiveTab()).toBe('tab2');
      
      const activePanel = document.querySelector('.tab-content.active');
      expect(activePanel.textContent).toBe('Content 2');
    });
    
    it('maintains active state after switching tabs', () => {
      const tabs = document.querySelectorAll('.mono-tab');
      fireEvent.click(tabs[1]);
      fireEvent.click(tabs[2]);
      
      expect(tabs[1].classList.contains('active')).toBe(false);
      expect(tabs[2].classList.contains('active')).toBe(true);
      expect(component.getActiveTab()).toBe('tab3');
    });
  });
  
  describe('Keyboard Navigation', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles arrow key navigation', () => {
      const firstTab = document.querySelector('.mono-tab');
      firstTab.focus();
      
      fireEvent.keyDown(firstTab, { key: 'ArrowRight' });
      expect(component.getActiveTab()).toBe('tab2');
      
      fireEvent.keyDown(document.activeElement, { key: 'ArrowRight' });
      expect(component.getActiveTab()).toBe('tab3');
      
      fireEvent.keyDown(document.activeElement, { key: 'ArrowLeft' });
      expect(component.getActiveTab()).toBe('tab2');
    });
    
    it('wraps around when navigating past edges', () => {
      const firstTab = document.querySelector('.mono-tab');
      firstTab.focus();
      
      fireEvent.keyDown(firstTab, { key: 'ArrowLeft' });
      expect(component.getActiveTab()).toBe('tab3');
      
      fireEvent.keyDown(document.activeElement, { key: 'ArrowRight' });
      expect(component.getActiveTab()).toBe('tab1');
    });
  });
  
  describe('Dynamic Tab Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('adds new tab', () => {
      component.addTab({
        id: 'tab4',
        label: 'Tab 4',
        content: 'Content 4'
      });
      
      const tabs = document.querySelectorAll('.mono-tab');
      expect(tabs.length).toBe(4);
      expect(tabs[3].textContent).toBe('Tab 4');
    });
    
    it('removes tab', () => {
      component.removeTab('tab2');
      
      const tabs = document.querySelectorAll('.mono-tab');
      expect(tabs.length).toBe(2);
      expect(Array.from(tabs).map(tab => tab.textContent)).toEqual(['Tab 1', 'Tab 3']);
    });
    
    it('updates tab content', () => {
      component.updateTab('tab1', {
        label: 'Updated Tab',
        content: 'Updated Content'
      });
      
      const tab = document.querySelector('.mono-tab');
      expect(tab.textContent).toBe('Updated Tab');
      
      const content = document.querySelector('.tab-content.active');
      expect(content.textContent).toBe('Updated Content');
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