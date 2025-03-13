/**
 * Info Box Component Tests
 * Simple test suite for the InfoBoxComponent
 */

import { InfoBoxComponent } from '../components/info_box';

// Helper function to create a test info box container
function createTestInfoBox(id = 'test-info-box') {
  const container = document.createElement('div');
  container.className = 'info-box';
  container.id = id;
  
  // Create close button
  const closeButton = document.createElement('button');
  closeButton.className = 'info-box__close';
  closeButton.textContent = '×';
  container.appendChild(closeButton);
  
  // Create content
  const content = document.createElement('div');
  content.className = 'info-box__content';
  content.textContent = 'This is a test info box';
  container.appendChild(content);
  
  // Add to document
  document.body.appendChild(container);
  
  return container;
}

// Initialize the component for testing
function testInfoBox() {
  console.log('➡️ Testing InfoBoxComponent');
  
  // Clear any existing dismissed boxes before testing
  localStorage.removeItem('dismissedInfoBoxes');
  
  // Create test elements
  const container = createTestInfoBox();
  
  try {
    // Create the component
    const component = new InfoBoxComponent({
      container: container,
      debug: true
    }).mount();
    
    // Test box ID
    console.log('  - Testing getBoxId() method');
    const boxId = component.getBoxId();
    console.log(`  - Box ID: ${boxId}`);
    
    // Test dismissal
    console.log('  - Testing dismiss() method');
    component.dismiss();
    
    // Verify dismissal state
    console.log('  - Checking isDismissed() method');
    const isDismissed = component.isDismissed();
    console.log(`  - Is dismissed: ${isDismissed}`);
    
    // Verify localStorage state
    const storedBoxes = localStorage.getItem('dismissedInfoBoxes');
    const parsedBoxes = storedBoxes ? JSON.parse(storedBoxes) : [];
    console.log(`  - Stored in localStorage: ${parsedBoxes.includes(boxId)}`);
    
    // Test the static method to clear dismissed boxes
    console.log('  - Testing static clearAllDismissed() method');
    InfoBoxComponent.clearAllDismissed();
    
    // Verify cleared state
    const clearedBoxes = localStorage.getItem('dismissedInfoBoxes');
    console.log(`  - Cleared from localStorage: ${clearedBoxes === null}`);
    
    // Clean up the component
    component.destroy();
    
    // Test persistence with a new component
    console.log('  - Testing persistence with a new component');
    
    // Add the box ID back to localStorage
    localStorage.setItem('dismissedInfoBoxes', JSON.stringify([boxId]));
    
    // Create a new info box with the same ID
    const container2 = createTestInfoBox(boxId);
    
    // Create a new component - it should automatically hide the box
    const component2 = new InfoBoxComponent({
      container: container2,
      debug: true
    }).mount();
    
    // The component should be dismissed immediately
    console.log(`  - Auto-dismissed based on localStorage: ${component2.isDismissed()}`);
    
    // Clean up the second component
    component2.destroy();
    
    console.log('✅ InfoBoxComponent tests passed');
  } catch (e) {
    console.error('❌ InfoBoxComponent tests failed', e);
  } finally {
    // Clean up test elements and localStorage
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    
    // Clean up localStorage
    localStorage.removeItem('dismissedInfoBoxes');
  }
}

// Run tests when this file is loaded directly
if (typeof window !== 'undefined' && window.runComponentTests) {
  window.addEventListener('DOMContentLoaded', () => {
    testInfoBox();
  });
}

export { testInfoBox }; 