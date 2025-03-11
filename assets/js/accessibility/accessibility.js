/**
 * Toggles the visibility of an accessibility description
 * @param {HTMLElement} button - The button that was clicked
 */
function toggleA11yDescription(button) {
  // Get the description element
  const descriptionId = button.getAttribute('aria-controls');
  const description = document.getElementById(descriptionId);
  
  // Check if the description is currently hidden
  const isHidden = description.hasAttribute('hidden');
  
  // Toggle the hidden attribute
  if (isHidden) {
    description.removeAttribute('hidden');
    button.setAttribute('aria-expanded', 'true');
    button.textContent = 'Hide text description';
  } else {
    description.setAttribute('hidden', '');
    button.setAttribute('aria-expanded', 'false');
    button.textContent = 'Show text description';
  }
  
  // Announce the change to screen readers
  const announcer = document.createElement('div');
  announcer.setAttribute('aria-live', 'polite');
  announcer.className = 'sr-only';
  document.body.appendChild(announcer);
  
  setTimeout(() => {
    announcer.textContent = isHidden 
      ? 'Text description shown' 
      : 'Text description hidden';
    
    // Remove the announcer after it's been read
    setTimeout(() => {
      document.body.removeChild(announcer);
    }, 1000);
  }, 100);
}

// Make the function globally available
window.toggleA11yDescription = toggleA11yDescription; 