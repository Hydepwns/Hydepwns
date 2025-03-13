/**
 * Debug Grid Toggle Component Tests
 * Simple sanity test for the DebugGridToggleComponent
 */

import { DebugGridToggleComponent } from '../components/debug_grid_toggle';

// Helper function to create a test checkbox
function createTestCheckbox() {
  const checkbox = document.createElement('input');
  checkbox.type = 'checkbox';
  checkbox.id = 'test-debug-toggle';
  document.body.appendChild(checkbox);
  return checkbox;
}

// Initialize the component for testing
function testDebugGridToggle() {
  console.log('➡️ Testing DebugGridToggleComponent');
  
  // Create test checkbox
  const checkbox = createTestCheckbox();
  
  try {
    // Create the component
    const component = new DebugGridToggleComponent({
      container: checkbox,
      debug: true
    }).mount();
    
    // Test toggle functionality
    console.log('  - Testing toggle on');
    component.enable();
    
    // Verify state
    const isEnabled = localStorage.getItem('debugGrid') === 'true';
    console.log(`  - Debug grid enabled: ${isEnabled}`);
    console.log(`  - Body has debug class: ${document.body.classList.contains('debug')}`);
    
    // Test toggle off
    console.log('  - Testing toggle off');
    component.disable();
    
    // Verify state
    const isDisabled = localStorage.getItem('debugGrid') !== 'true';
    console.log(`  - Debug grid disabled: ${isDisabled}`);
    console.log(`  - Body no debug class: ${!document.body.classList.contains('debug')}`);
    
    // Clean up
    component.destroy();
    
    console.log('✅ DebugGridToggleComponent tests passed');
  } catch (e) {
    console.error('❌ DebugGridToggleComponent tests failed', e);
  } finally {
    // Clean up test elements
    if (checkbox && checkbox.parentNode) {
      checkbox.parentNode.removeChild(checkbox);
    }
  }
}

// Run tests when this file is loaded directly
if (typeof window !== 'undefined' && window.runComponentTests) {
  window.addEventListener('DOMContentLoaded', () => {
    testDebugGridToggle();
  });
}

export { testDebugGridToggle }; 