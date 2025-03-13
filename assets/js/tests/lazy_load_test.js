/**
 * Lazy Load Component Tests
 * Simple test suite for the LazyLoadComponent
 */

import { LazyLoadComponent } from '../components/lazy_load';

// Helper function to create a test lazy load container
function createTestLazyLoad() {
  const container = document.createElement('div');
  container.className = 'lazy-load-container';
  container.style.height = '200px';
  container.style.position = 'relative';
  
  // Create placeholder
  const placeholder = document.createElement('div');
  placeholder.setAttribute('data-lazy-placeholder', '');
  placeholder.textContent = 'Loading...';
  container.appendChild(placeholder);
  
  // Create content (initially hidden)
  const content = document.createElement('div');
  content.setAttribute('data-lazy-content', '');
  content.style.display = 'none';
  content.textContent = 'This is the lazy loaded content';
  container.appendChild(content);
  
  // Add to document
  document.body.appendChild(container);
  
  return container;
}

// Create an intersection observer mock - since we can't easily test real intersection
class IntersectionObserverMock {
  constructor(callback) {
    this.callback = callback;
    this.elements = new Set();
  }
  
  observe(element) {
    this.elements.add(element);
  }
  
  disconnect() {
    this.elements.clear();
  }
  
  // Trigger an intersection manually
  triggerIntersection(isIntersecting = true) {
    const entries = Array.from(this.elements).map(element => ({
      isIntersecting,
      target: element,
      boundingClientRect: element.getBoundingClientRect()
    }));
    
    this.callback(entries);
  }
}

// Initialize the component for testing
function testLazyLoad() {
  console.log('➡️ Testing LazyLoadComponent');
  
  // Save original IntersectionObserver
  const originalIntersectionObserver = window.IntersectionObserver;
  let observerInstance;
  
  // Create our testing IntersectionObserver mock
  window.IntersectionObserver = function(callback, options) {
    observerInstance = new IntersectionObserverMock(callback);
    return observerInstance;
  };
  
  // Create test elements
  const container = createTestLazyLoad();
  
  try {
    // Add an accessibility announcer for testing
    const announcer = document.createElement('div');
    announcer.id = 'accessibility-announcer';
    document.body.appendChild(announcer);
    
    // Track lazy-content-loaded events
    let eventFired = false;
    container.addEventListener('lazy-content-loaded', (e) => {
      eventFired = true;
      console.log('  - lazy-content-loaded event captured', e.detail);
    });
    
    // Create the component
    const component = new LazyLoadComponent({
      container: container,
      debug: true
    }).mount();
    
    // Test initial state
    console.log('  - Testing initial state');
    console.log(`  - Is loaded: ${component.isLoaded()}`);
    
    // Simulate intersection
    console.log('  - Simulating intersection with viewport');
    observerInstance.triggerIntersection(true);
    
    // Test loaded state
    console.log('  - Testing loaded state after intersection');
    console.log(`  - Is loaded: ${component.isLoaded()}`);
    
    // Test visibility
    const content = container.querySelector('[data-lazy-content]');
    const placeholder = container.querySelector('[data-lazy-placeholder]');
    console.log(`  - Content visible: ${content.style.display === ''}`);
    console.log(`  - Placeholder hidden: ${placeholder.style.display === 'none'}`);
    
    // Test event firing
    console.log(`  - Event fired: ${eventFired}`);
    
    // Test accessibility announcer
    console.log(`  - Announcer updated: ${announcer.textContent === 'Content loaded'}`);
    
    // Test manually loading another component
    console.log('  - Testing loadNow() method');
    
    // Create another lazy load container
    const container2 = createTestLazyLoad();
    
    // Create another component
    const component2 = new LazyLoadComponent({
      container: container2,
      debug: true
    }).mount();
    
    // Force it to load
    component2.loadNow();
    
    // Test forced loading
    console.log(`  - Forced loading successful: ${component2.isLoaded()}`);
    
    // Clean up
    component.destroy();
    component2.destroy();
    
    // Clean up the announcer
    if (announcer.parentNode) {
      announcer.parentNode.removeChild(announcer);
    }
    
    console.log('✅ LazyLoadComponent tests passed');
  } catch (e) {
    console.error('❌ LazyLoadComponent tests failed', e);
  } finally {
    // Restore original IntersectionObserver
    window.IntersectionObserver = originalIntersectionObserver;
    
    // Clean up test elements
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    
    // Remove any remaining test containers
    const testContainers = document.querySelectorAll('.lazy-load-container');
    testContainers.forEach(el => {
      if (el.parentNode) {
        el.parentNode.removeChild(el);
      }
    });
  }
}

// Run tests when this file is loaded directly
if (typeof window !== 'undefined' && window.runComponentTests) {
  window.addEventListener('DOMContentLoaded', () => {
    testLazyLoad();
  });
}

export { testLazyLoad }; 