/**
 * Navigation Menu Component Tests
 * ------------------------
 * Tests for the NavigationMenu component that provides the main navigation interface.
 */

import { NavigationMenuComponent } from '../../../assets/js/components/navigation_menu';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('NavigationMenu Component', () => {
  let testContainer;
  let component;
  
  const mockMenuItems = [
    { id: 'home', label: 'Home', url: '/' },
    { 
      id: 'docs', 
      label: 'Documentation',
      url: '/docs',
      submenu: [
        { id: 'getting-started', label: 'Getting Started', url: '/docs/getting-started' },
        { id: 'api', label: 'API Reference', url: '/docs/api' }
      ]
    },
    { id: 'about', label: 'About', url: '/about' }
  ];
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the navigation menu element
    const menuElement = document.createElement('nav');
    menuElement.className = 'navigation-menu';
    menuElement.setAttribute('data-active-item', 'home');
    testContainer.appendChild(menuElement);
    
    // Initialize the component
    component = new NavigationMenuComponent(menuElement, { items: mockMenuItems });
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
      expect(component.options.items).toEqual(mockMenuItems);
      expect(component.getActiveItem()).toBe('home');
    });
    
    it('creates menu structure', () => {
      component.initialize();
      
      const menuItems = document.querySelectorAll('.nav-item');
      expect(menuItems.length).toBe(3);
      
      const submenuItems = document.querySelectorAll('.submenu-item');
      expect(submenuItems.length).toBe(2);
    });
    
    it('sets initial active state', () => {
      component.initialize();
      
      const activeItem = document.querySelector('.nav-item.active');
      expect(activeItem.textContent).toBe('Home');
    });
  });
  
  describe('Navigation Operations', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles item selection', () => {
      const aboutItem = Array.from(document.querySelectorAll('.nav-item'))
        .find(item => item.textContent === 'About');
      
      fireEvent.click(aboutItem);
      expect(aboutItem.classList.contains('active')).toBe(true);
      expect(component.getActiveItem()).toBe('about');
    });
    
    it('toggles submenu visibility', () => {
      const docsItem = Array.from(document.querySelectorAll('.nav-item'))
        .find(item => item.textContent === 'Documentation');
      
      fireEvent.click(docsItem);
      
      const submenu = document.querySelector('.submenu');
      expect(submenu.classList.contains('visible')).toBe(true);
    });
    
    it('handles submenu item selection', () => {
      const apiItem = Array.from(document.querySelectorAll('.submenu-item'))
        .find(item => item.textContent === 'API Reference');
      
      fireEvent.click(apiItem);
      expect(apiItem.classList.contains('active')).toBe(true);
      expect(component.getActiveItem()).toBe('api');
    });
  });
  
  describe('Keyboard Navigation', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles arrow key navigation', () => {
      const firstItem = document.querySelector('.nav-item');
      firstItem.focus();
      
      fireEvent.keyDown(firstItem, { key: 'ArrowDown' });
      expect(document.activeElement.textContent).toBe('Documentation');
      
      fireEvent.keyDown(document.activeElement, { key: 'ArrowDown' });
      expect(document.activeElement.textContent).toBe('About');
    });
    
    it('handles submenu keyboard navigation', () => {
      const docsItem = Array.from(document.querySelectorAll('.nav-item'))
        .find(item => item.textContent === 'Documentation');
      
      docsItem.focus();
      fireEvent.keyDown(docsItem, { key: 'Enter' });
      
      const submenu = document.querySelector('.submenu');
      expect(submenu.classList.contains('visible')).toBe(true);
      
      fireEvent.keyDown(document.activeElement, { key: 'ArrowRight' });
      expect(document.activeElement.textContent).toBe('Getting Started');
    });
  });
  
  describe('Mobile Responsiveness', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('toggles mobile menu', () => {
      const mobileToggle = document.querySelector('.mobile-toggle');
      fireEvent.click(mobileToggle);
      
      const menu = document.querySelector('.navigation-menu');
      expect(menu.classList.contains('mobile-visible')).toBe(true);
    });
    
    it('closes mobile menu on item selection', () => {
      const mobileToggle = document.querySelector('.mobile-toggle');
      fireEvent.click(mobileToggle);
      
      const aboutItem = Array.from(document.querySelectorAll('.nav-item'))
        .find(item => item.textContent === 'About');
      fireEvent.click(aboutItem);
      
      const menu = document.querySelector('.navigation-menu');
      expect(menu.classList.contains('mobile-visible')).toBe(false);
    });
  });
  
  describe('Dynamic Menu Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('adds new menu item', () => {
      component.addItem({
        id: 'contact',
        label: 'Contact',
        url: '/contact'
      });
      
      const menuItems = document.querySelectorAll('.nav-item');
      expect(menuItems.length).toBe(4);
      expect(menuItems[3].textContent).toBe('Contact');
    });
    
    it('removes menu item', () => {
      component.removeItem('about');
      
      const menuItems = document.querySelectorAll('.nav-item');
      expect(menuItems.length).toBe(2);
      expect(Array.from(menuItems).map(item => item.textContent))
        .toEqual(['Home', 'Documentation']);
    });
    
    it('updates menu item', () => {
      component.updateItem('home', {
        label: 'Homepage',
        url: '/home'
      });
      
      const homeItem = document.querySelector('.nav-item');
      expect(homeItem.textContent).toBe('Homepage');
      expect(homeItem.getAttribute('href')).toBe('/home');
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