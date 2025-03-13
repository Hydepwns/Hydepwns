/**
 * Diagram Editor Component Tests
 * Simple test suite for the DiagramEditorComponent
 */

import { DiagramEditorComponent } from '../components/diagram_editor';

// Helper function to create a test editor container
function createTestEditorContainer() {
  const container = document.createElement('div');
  container.className = 'diagram-editor-container';
  
  // Create textarea
  const textarea = document.createElement('textarea');
  textarea.className = 'diagram-editor';
  textarea.value = 'Initial diagram text';
  container.appendChild(textarea);
  
  // Create preview section
  const previewSection = document.createElement('div');
  previewSection.className = 'diagram-preview';
  
  const previewCode = document.createElement('code');
  previewSection.appendChild(previewCode);
  
  container.appendChild(previewSection);
  
  // Add to document
  document.body.appendChild(container);
  
  return container;
}

// Initialize the component for testing
function testDiagramEditor() {
  console.log('➡️ Testing DiagramEditorComponent');
  
  // Create test elements
  const container = createTestEditorContainer();
  
  try {
    // Create the component
    const component = new DiagramEditorComponent({
      container: container,
      debug: true,
      tabSize: 4
    }).mount();
    
    // Test setting text
    console.log('  - Testing setText() method');
    component.setText('New diagram content');
    
    // Test getting text
    console.log('  - Testing getText() method');
    const text = component.getText();
    console.log(`  - Current text: ${text}`);
    
    // Test inserting at cursor
    console.log('  - Testing insertAtCursor() method');
    
    // First focus the editor and set cursor position (simulate user selecting position)
    const textarea = container.querySelector('textarea');
    textarea.focus();
    textarea.selectionStart = 4; // After "New "
    textarea.selectionEnd = 4;
    
    // Insert text at cursor
    component.insertAtCursor('-TEST-');
    
    // Check result
    const newText = component.getText();
    console.log(`  - Text after insertion: ${newText}`);
    
    // Test clipboard functionality (just check if the method runs)
    console.log('  - Testing copyToClipboard() method');
    component.copyToClipboard('Test clipboard text', 'Test notification');
    
    // Clean up the component
    component.destroy();
    
    console.log('✅ DiagramEditorComponent tests passed');
  } catch (e) {
    console.error('❌ DiagramEditorComponent tests failed', e);
  } finally {
    // Clean up test elements
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
  }
}

// Run tests when this file is loaded directly
if (typeof window !== 'undefined' && window.runComponentTests) {
  window.addEventListener('DOMContentLoaded', () => {
    testDiagramEditor();
  });
}

export { testDiagramEditor }; 