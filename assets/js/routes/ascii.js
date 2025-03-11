/**
 * ASCII Art Route Bundle
 * 
 * This file contains all JavaScript that's specific to the ASCII art routes.
 * It's loaded dynamically only when a user visits ASCII art related pages.
 */
import { liveSocket, Hooks } from '../entrypoints/app';
import AsciiArtGenerator from "../hooks/ascii_art_generator";
import CopyableCode from "../hooks/copyable_code";

// Register route-specific hooks
Hooks.AsciiArtGenerator = AsciiArtGenerator;
Hooks.CopyableCode = CopyableCode;

// Update the LiveSocket with new hooks
liveSocket.updateHooks(Hooks);

// Initialize ASCII art specific functionality
console.log('Initializing ASCII art specific functionality');

// ASCII-specific utility functions could be defined here
const exportAsciiArt = (ascii) => {
  const blob = new Blob([ascii], { type: 'text/plain' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'ascii-art.txt';
  a.click();
  URL.revokeObjectURL(url);
};

// Make functions available globally if needed
window.asciiUtils = {
  exportAsciiArt
};

// Export hooks and utilities for potential use in other modules
export { Hooks, exportAsciiArt }; 