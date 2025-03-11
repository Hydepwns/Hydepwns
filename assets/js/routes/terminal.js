/**
 * Terminal Route Bundle
 * 
 * This file contains all JavaScript that's specific to the terminal routes.
 * It's loaded dynamically only when a user visits terminal related pages.
 */
import { liveSocket, Hooks } from '../entrypoints/app';
import Terminal from "../hooks/terminal";
import CopyableCode from "../hooks/copyable_code";

// Register route-specific hooks
Hooks.Terminal = Terminal;
Hooks.CopyableCode = CopyableCode;

// Update the LiveSocket with new hooks
liveSocket.updateHooks(Hooks);

// Initialize terminal specific functionality
console.log('Initializing terminal specific functionality');

// Terminal command history management
const HISTORY_KEY = 'terminal_command_history';
const MAX_HISTORY_LENGTH = 100;

const terminalUtils = {
  saveCommandToHistory: (command) => {
    if (!command.trim()) return;
    
    try {
      let history = JSON.parse(localStorage.getItem(HISTORY_KEY) || '[]');
      
      // Don't add duplicate consecutive commands
      if (history.length > 0 && history[0] === command) {
        return;
      }
      
      // Add new command to beginning
      history.unshift(command);
      
      // Limit history length
      if (history.length > MAX_HISTORY_LENGTH) {
        history = history.slice(0, MAX_HISTORY_LENGTH);
      }
      
      localStorage.setItem(HISTORY_KEY, JSON.stringify(history));
    } catch (e) {
      console.error('Failed to save command to history:', e);
    }
  },
  
  getCommandHistory: () => {
    try {
      return JSON.parse(localStorage.getItem(HISTORY_KEY) || '[]');
    } catch (e) {
      console.error('Failed to get command history:', e);
      return [];
    }
  },
  
  clearCommandHistory: () => {
    localStorage.removeItem(HISTORY_KEY);
  }
};

// Make functions available globally if needed
window.terminalUtils = terminalUtils;

// Export hooks and utilities for potential use in other modules
export { Hooks, terminalUtils }; 