/**
 * Terminal Offline Support
 * 
 * This module provides offline functionality for the terminal component,
 * allowing users to continue using the terminal when offline.
 * 
 * Features:
 * - Detection of online/offline status changes
 * - Local command execution when offline
 * - Caching of command history and preferences
 * - Syncing cached data when back online
 * - Offline indicator in the terminal UI
 */

const TerminalOffline = {
  /**
   * Initialize offline support for terminals
   */
  init() {
    // Add online/offline event listeners
    window.addEventListener('online', this.handleOnlineStatus.bind(this));
    window.addEventListener('offline', this.handleOfflineStatus.bind(this));
    
    // Initialize offline status
    this.isOffline = !navigator.onLine;
    
    // Store references to terminal elements
    this.terminals = {};
    
    // Set up message handler for service worker communication
    if (navigator.serviceWorker) {
      navigator.serviceWorker.addEventListener('message', this.handleServiceWorkerMessage.bind(this));
    }
    
    // Add custom event listeners for terminal events
    document.addEventListener('terminal:command', this.handleTerminalCommand.bind(this));
    document.addEventListener('terminal:preferences:update', this.handleTerminalPreferences.bind(this));
    
    // Run initial setup
    this.setupOfflineFunctionality();
    
    console.log(`Terminal offline support initialized. Current status: ${this.isOffline ? 'Offline' : 'Online'}`);
  },
  
  /**
   * Set up offline functionality on page load
   */
  setupOfflineFunctionality() {
    // Find all terminal elements on the page
    const terminalElements = document.querySelectorAll('[data-terminal-id]');
    
    terminalElements.forEach(terminal => {
      const terminalId = terminal.dataset.terminalId;
      
      // Store reference to the terminal
      this.terminals[terminalId] = {
        element: terminal,
        id: terminalId,
        offlineIndicator: null
      };
      
      // If offline, add indicator
      if (this.isOffline) {
        this.addOfflineIndicator(terminal, terminalId);
      }
    });
  },
  
  /**
   * Handle online status change
   */
  handleOnlineStatus() {
    console.log('Terminal is back online');
    this.isOffline = false;
    
    // Remove offline indicators from all terminals
    Object.keys(this.terminals).forEach(terminalId => {
      this.removeOfflineIndicator(this.terminals[terminalId].element, terminalId);
    });
    
    // Trigger sync of cached data
    this.syncCachedData();
    
    // Dispatch event for other components
    document.dispatchEvent(new CustomEvent('terminal:online'));
  },
  
  /**
   * Handle offline status change
   */
  handleOfflineStatus() {
    console.log('Terminal is now offline');
    this.isOffline = true;
    
    // Add offline indicators to all terminals
    Object.keys(this.terminals).forEach(terminalId => {
      this.addOfflineIndicator(this.terminals[terminalId].element, terminalId);
    });
    
    // Dispatch event for other components
    document.dispatchEvent(new CustomEvent('terminal:offline'));
  },
  
  /**
   * Add offline indicator to terminal
   */
  addOfflineIndicator(terminal, terminalId) {
    // Don't add if already exists
    if (this.terminals[terminalId].offlineIndicator) return;
    
    // Create offline indicator element
    const indicator = document.createElement('div');
    indicator.className = 'terminal-offline-indicator';
    indicator.innerHTML = `
      <span class="offline-icon">⚠</span>
      <span class="offline-text">Offline Mode</span>
    `;
    
    // Add to terminal header
    const terminalHeader = terminal.querySelector('.terminal-header');
    if (terminalHeader) {
      terminalHeader.appendChild(indicator);
      this.terminals[terminalId].offlineIndicator = indicator;
    }
    
    // Add offline class to terminal
    terminal.classList.add('terminal-offline');
    
    // Add offline message to terminal output
    this.addOfflineMessage(terminalId);
  },
  
  /**
   * Remove offline indicator from terminal
   */
  removeOfflineIndicator(terminal, terminalId) {
    // Remove indicator if it exists
    if (this.terminals[terminalId].offlineIndicator) {
      this.terminals[terminalId].offlineIndicator.remove();
      this.terminals[terminalId].offlineIndicator = null;
    }
    
    // Remove offline class
    terminal.classList.remove('terminal-offline');
    
    // Add back online message to terminal output
    this.addOnlineMessage(terminalId);
  },
  
  /**
   * Add offline message to terminal output
   */
  addOfflineMessage(terminalId) {
    // Dispatch custom event to add message to terminal output
    document.dispatchEvent(new CustomEvent('terminal:addsystemmessage', {
      detail: {
        terminalId: terminalId,
        message: 'Terminal is now in offline mode. Some commands may have limited functionality.'
      }
    }));
  },
  
  /**
   * Add back online message to terminal output
   */
  addOnlineMessage(terminalId) {
    // Dispatch custom event to add message to terminal output
    document.dispatchEvent(new CustomEvent('terminal:addsystemmessage', {
      detail: {
        terminalId: terminalId,
        message: 'Terminal is back online. Syncing your command history and preferences...'
      }
    }));
  },
  
  /**
   * Handle terminal command
   */
  handleTerminalCommand(event) {
    const { terminalId, command } = event.detail;
    
    // If online, no special handling needed
    if (!this.isOffline) return;
    
    console.log(`Handling offline terminal command: ${command} for terminal: ${terminalId}`);
    
    // Store command in service worker cache
    this.cacheTerminalCommand({
      terminalId,
      command,
      timestamp: Date.now()
    });
    
    // Process command locally if possible
    const result = this.processOfflineCommand(command);
    
    // Dispatch event with result
    document.dispatchEvent(new CustomEvent('terminal:commandresult', {
      detail: {
        terminalId,
        result,
        offline: true
      }
    }));
    
    // Prevent default handling
    event.preventDefault();
  },
  
  /**
   * Handle terminal preferences update
   */
  handleTerminalPreferences(event) {
    const { terminalId, preferences } = event.detail;
    
    // Always cache preferences, whether online or offline
    this.cacheTerminalPreferences({
      id: terminalId,
      ...preferences
    });
  },
  
  /**
   * Process command locally when offline
   */
  processOfflineCommand(command) {
    // Split command into parts
    const parts = command.trim().split(' ');
    const cmd = parts[0].toLowerCase();
    const args = parts.slice(1).join(' ');
    
    // Simple offline command processor
    switch (cmd) {
      case 'help':
        return {
          output: [
            {
              type: 'system',
              content: `
Offline Commands Available:

  help                  - Show this help message
  clear                 - Clear the terminal screen
  echo [text]           - Display text
  status                - Show offline status
  date                  - Show current date and time
              `
            }
          ],
          status: 'success'
        };
        
      case 'clear':
        return {
          output: [],
          clear: true,
          status: 'success'
        };
        
      case 'echo':
        return {
          output: [
            {
              type: 'output',
              content: args || ''
            }
          ],
          status: 'success'
        };
        
      case 'status':
        return {
          output: [
            {
              type: 'system',
              content: `
Status: Offline
Connection: None
Cached Commands: ${this.getCachedCommandCount()}
Last Online: ${this.getLastOnlineTime()}
`
            }
          ],
          status: 'success'
        };
      
      case 'date':
        return {
          output: [
            {
              type: 'output',
              content: new Date().toString()
            }
          ],
          status: 'success'
        };
        
      default:
        return {
          output: [
            {
              type: 'error',
              content: `Command '${cmd}' not available offline. It will be processed when you're back online.`
            }
          ],
          status: 'error'
        };
    }
  },
  
  /**
   * Cache terminal command via service worker
   */
  cacheTerminalCommand(commandData) {
    if (navigator.serviceWorker && navigator.serviceWorker.controller) {
      navigator.serviceWorker.controller.postMessage({
        type: 'CACHE_TERMINAL_COMMAND',
        payload: commandData
      });
    } else {
      // Fallback to localStorage if service worker not available
      const commands = JSON.parse(localStorage.getItem('terminal_commands') || '[]');
      commands.push(commandData);
      localStorage.setItem('terminal_commands', JSON.stringify(commands));
    }
  },
  
  /**
   * Cache terminal preferences via service worker
   */
  cacheTerminalPreferences(preferences) {
    if (navigator.serviceWorker && navigator.serviceWorker.controller) {
      navigator.serviceWorker.controller.postMessage({
        type: 'CACHE_TERMINAL_PREFERENCES',
        payload: preferences
      });
    } else {
      // Fallback to localStorage if service worker not available
      localStorage.setItem(`terminal_preferences_${preferences.id}`, JSON.stringify(preferences));
    }
  },
  
  /**
   * Sync cached data when back online
   */
  syncCachedData() {
    // Trigger background sync if available
    if (navigator.serviceWorker && 'sync' in window.registration) {
      navigator.serviceWorker.ready.then(registration => {
        registration.sync.register('terminal-sync');
      });
    } else {
      console.log('Background sync not supported. Manually syncing cached data.');
      this.manualSyncCachedData();
    }
  },
  
  /**
   * Manually sync cached data when background sync not available
   */
  manualSyncCachedData() {
    // Get commands from localStorage fallback if used
    const commands = JSON.parse(localStorage.getItem('terminal_commands') || '[]');
    
    if (commands.length > 0) {
      // Send commands to server
      fetch('/api/terminal/sync', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ commands })
      })
      .then(() => {
        // Clear cached commands
        localStorage.removeItem('terminal_commands');
      })
      .catch(error => {
        console.error('Failed to sync terminal commands:', error);
      });
    }
    
    // Sync preferences from localStorage fallback if used
    this.syncLocalStoragePreferences();
  },
  
  /**
   * Sync preferences from localStorage fallback
   */
  syncLocalStoragePreferences() {
    // Find all terminal preference items in localStorage
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key.startsWith('terminal_preferences_')) {
        try {
          const preferences = JSON.parse(localStorage.getItem(key));
          
          // Send to server
          fetch('/api/terminal/preferences/sync', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(preferences)
          })
          .then(() => {
            // Keep preferences in localStorage for offline use
            // But mark as synced by adding the synced flag
            preferences.synced = true;
            localStorage.setItem(key, JSON.stringify(preferences));
          })
          .catch(error => {
            console.error(`Failed to sync terminal preferences for ${key}:`, error);
          });
        } catch (error) {
          console.error(`Failed to parse preferences for ${key}:`, error);
        }
      }
    }
  },
  
  /**
   * Handle messages from service worker
   */
  handleServiceWorkerMessage(event) {
    if (event.data.type === 'TERMINAL_SYNC_COMPLETE') {
      console.log('Terminal data sync completed');
      
      // Notify terminals
      Object.keys(this.terminals).forEach(terminalId => {
        document.dispatchEvent(new CustomEvent('terminal:addsystemmessage', {
          detail: {
            terminalId: terminalId,
            message: 'Your offline commands and preferences have been synced.'
          }
        }));
      });
    }
  },
  
  /**
   * Get count of cached commands
   */
  getCachedCommandCount() {
    // Try to get count from service worker
    // For simplicity, use localStorage fallback for the demo
    const commands = JSON.parse(localStorage.getItem('terminal_commands') || '[]');
    return commands.length;
  },
  
  /**
   * Get last online time
   */
  getLastOnlineTime() {
    const lastOnline = localStorage.getItem('terminal_last_online');
    if (lastOnline) {
      return new Date(parseInt(lastOnline)).toString();
    }
    return 'Unknown';
  }
};

// Store last online time when going offline
window.addEventListener('offline', () => {
  localStorage.setItem('terminal_last_online', Date.now().toString());
});

// Initialize when the DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  TerminalOffline.init();
});

// Export for use in other modules
export default TerminalOffline; 