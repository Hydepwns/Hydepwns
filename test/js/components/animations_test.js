/**
 * Animation Components Tests
 * -----------------------
 * Tests for animation components that provide text and grid-based animations.
 */

import { CharacterAnimationComponent, GridFadeInComponent } from '../../../assets/js/components/animations';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe.skip('Animation Components', () => {
  // Common variables and setups
  let testContainer;
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Mock matchMedia for reduced motion tests
    window.matchMedia = jest.fn().mockImplementation(query => {
      return {
        matches: false,
        media: query,
        onchange: null,
        addListener: jest.fn(),
        removeListener: jest.fn(),
        addEventListener: jest.fn(),
        removeEventListener: jest.fn(),
        dispatchEvent: jest.fn(),
      };
    });
  });
  
  afterEach(() => {
    if (testContainer && testContainer.parentNode) {
      testContainer.parentNode.removeChild(testContainer);
    }
    jest.restoreAllMocks();
  });
  
  describe('CharacterAnimationComponent', () => {
    let component;
    let element;
    
    beforeEach(() => {
      element = document.createElement('div');
      element.innerHTML = `
        <div class="character-animation" data-text="Hello World">
          <span class="character">H</span>
          <span class="character">e</span>
          <span class="character">l</span>
          <span class="character">l</span>
          <span class="character">o</span>
        </div>
      `;
      testContainer.appendChild(element);
      
      // Spy on animation methods
      jest.spyOn(window, 'requestAnimationFrame').mockImplementation(cb => setTimeout(cb, 0));
      jest.spyOn(window, 'cancelAnimationFrame').mockImplementation(id => clearTimeout(id));
    });
    
    it('initializes properly with default options', () => {
      component = new CharacterAnimationComponent(element.querySelector('.character-animation'));
      
      // Use Jest's expect instead of Chai's
      expect(component).toBeDefined();
      expect(component.element).toBeDefined();
      expect(component.characters.length).toBeGreaterThan(0);
      expect(component.isAnimating).toBe(false);
    });
    
    it('starts animation when in viewport', () => {
      // Mock IntersectionObserver
      const mockIntersectionObserver = jest.fn();
      mockIntersectionObserver.mockReturnValue({
        observe: jest.fn(),
        unobserve: jest.fn(),
        disconnect: jest.fn()
      });
      window.IntersectionObserver = mockIntersectionObserver;
      
      component = new CharacterAnimationComponent(element.querySelector('.character-animation'));
      
      // Trigger intersection
      const [callback] = mockIntersectionObserver.mock.calls[0];
      callback([{ isIntersecting: true }]);
      
      // Use Jest's expect instead of Chai's
      expect(component.isAnimating).toBe(true);
    });
    
    it('respects reduced motion preferences', () => {
      // Mock matchMedia to indicate preference for reduced motion
      window.matchMedia = jest.fn().mockImplementation(query => {
        return {
          matches: query.includes('reduce'),
          media: query,
          onchange: null,
          addListener: jest.fn(),
          removeListener: jest.fn(),
          addEventListener: jest.fn(),
          removeEventListener: jest.fn(),
          dispatchEvent: jest.fn(),
        };
      });
      
      component = new CharacterAnimationComponent(element.querySelector('.character-animation'));
      
      // Trigger animation
      component.startAnimation();
      
      // Use Jest's expect instead of Chai's
      expect(component.isAnimating).toBe(false);
      expect(component.characters.every(char => char.style.opacity === '1')).toBe(true);
    });
    
    it('cleans up properly on destroy', () => {
      component = new CharacterAnimationComponent(element.querySelector('.character-animation'));
      
      // Spy on cleanup methods
      const disconnectSpy = jest.spyOn(component.observer, 'disconnect');
      
      // Destroy component
      component.destroy();
      
      // Use Jest's expect instead of Chai's
      expect(disconnectSpy).toHaveBeenCalled();
      expect(component.isAnimating).toBe(false);
    });
  });
  
  describe('GridFadeInComponent', () => {
    let component;
    let element;
    
    beforeEach(() => {
      element = document.createElement('div');
      element.innerHTML = `
        <div class="grid-fade-in">
          <div class="grid-item"></div>
          <div class="grid-item"></div>
          <div class="grid-item"></div>
          <div class="grid-item"></div>
        </div>
      `;
      testContainer.appendChild(element);
      
      // Spy on animation methods
      jest.spyOn(window, 'requestAnimationFrame').mockImplementation(cb => setTimeout(cb, 0));
      jest.spyOn(window, 'cancelAnimationFrame').mockImplementation(id => clearTimeout(id));
    });
    
    it('initializes properly with default options', () => {
      component = new GridFadeInComponent(element.querySelector('.grid-fade-in'));
      
      // Use Jest's expect instead of Chai's
      expect(component).toBeDefined();
      expect(component.element).toBeDefined();
      expect(component.items.length).toBe(4);
      expect(component.isAnimating).toBe(false);
    });
    
    it('starts animation when in viewport', () => {
      // Mock IntersectionObserver
      const mockIntersectionObserver = jest.fn();
      mockIntersectionObserver.mockReturnValue({
        observe: jest.fn(),
        unobserve: jest.fn(),
        disconnect: jest.fn()
      });
      window.IntersectionObserver = mockIntersectionObserver;
      
      component = new GridFadeInComponent(element.querySelector('.grid-fade-in'));
      
      // Trigger intersection
      const [callback] = mockIntersectionObserver.mock.calls[0];
      callback([{ isIntersecting: true }]);
      
      // Use Jest's expect instead of Chai's
      expect(component.isAnimating).toBe(true);
    });
    
    it('respects reduced motion preferences', () => {
      // Mock matchMedia to indicate preference for reduced motion
      window.matchMedia = jest.fn().mockImplementation(query => {
        return {
          matches: query.includes('reduce'),
          media: query,
          onchange: null,
          addListener: jest.fn(),
          removeListener: jest.fn(),
          addEventListener: jest.fn(),
          removeEventListener: jest.fn(),
          dispatchEvent: jest.fn(),
        };
      });
      
      component = new GridFadeInComponent(element.querySelector('.grid-fade-in'));
      
      // Trigger animation
      component.startAnimation();
      
      // Use Jest's expect instead of Chai's
      expect(component.isAnimating).toBe(false);
      expect(component.items.every(item => item.style.opacity === '1')).toBe(true);
    });
    
    it('cleans up properly on destroy', () => {
      component = new GridFadeInComponent(element.querySelector('.grid-fade-in'));
      
      // Spy on cleanup methods
      const disconnectSpy = jest.spyOn(component.observer, 'disconnect');
      
      // Destroy component
      component.destroy();
      
      // Use Jest's expect instead of Chai's
      expect(disconnectSpy).toHaveBeenCalled();
      expect(component.isAnimating).toBe(false);
    });
  });
}); 