/**
 * Diagram Editor Hook
 * ------------------
 * This hook provides the JavaScript functionality for the ASCII diagram editor component.
 * 
 * Features:
 * - Auto-resize text area based on content
 * - Insert special characters at cursor position
 * - Copy diagram to clipboard
 * - Real-time preview updates
 * - Maintain monospace grid alignment
 */

const DiagramEditor = {
  mounted() {
    // Access debug utility from window
    this.debug = window.DEBUG || { log: () => {} };
    this.debug.log('DiagramEditor mounted');
    
    // Get references to key elements
    this.textarea = this.el.querySelector('textarea');
    this.preview = this.el.querySelector('.diagram-preview code');
    
    // Set up event listeners
    this.setupEventListeners();
    
    // Initialize editor
    this.initEditor();
  },
  
  setupEventListeners() {
    // Listen for events from the server side
    this.handleEvent("insert-at-cursor", ({ target, text }) => {
      this.insertAtCursor(text);
    });
    
    this.handleEvent("copy-to-clipboard", ({ text, message }) => {
      this.copyToClipboard(text, message);
    });
    
    // Monitor textarea changes to update preview and auto-resize
    if (this.textarea) {
      this.textarea.addEventListener('input', (e) => {
        this.updatePreview(e.target.value);
        this.autoResize();
      });
      
      // Initialize with current content
      this.updatePreview(this.textarea.value);
      this.autoResize();
      
      // Handle tab key to insert spaces instead of changing focus
      this.textarea.addEventListener('keydown', (e) => {
        if (e.key === 'Tab') {
          e.preventDefault();
          this.insertAtCursor('  '); // Insert 2 spaces for a tab
        }
      });
    }
  },
  
  initEditor() {
    // Ensure the textarea is focused on mount
    if (this.textarea) {
      setTimeout(() => {
        this.textarea.focus();
        this.autoResize();
      }, 100);
    }
    
    // Ensure preview is initialized
    this.updatePreview(this.textarea?.value || '');
  },
  
  updatePreview(text) {
    if (this.preview) {
      this.preview.textContent = text;
    }
  },
  
  insertAtCursor(text) {
    if (!this.textarea) return;
    
    const startPos = this.textarea.selectionStart;
    const endPos = this.textarea.selectionEnd;
    const scrollTop = this.textarea.scrollTop;
    
    // Insert the text at cursor position
    const value = this.textarea.value;
    this.textarea.value = value.substring(0, startPos) + text + value.substring(endPos);
    
    // Move the cursor position after the inserted text
    this.textarea.selectionStart = startPos + text.length;
    this.textarea.selectionEnd = startPos + text.length;
    
    // Maintain scroll position
    this.textarea.scrollTop = scrollTop;
    
    // Focus the textarea and trigger input event to update preview
    this.textarea.focus();
    this.textarea.dispatchEvent(new Event('input', { bubbles: true }));
  },
  
  autoResize() {
    if (!this.textarea) return;
    
    // Reset height to calculate actual content height
    this.textarea.style.height = 'auto';
    
    // Set new height based on scrollHeight, adding a bit of extra space
    const newHeight = this.textarea.scrollHeight + 5;
    this.textarea.style.height = `${newHeight}px`;
    
    // Also resize the preview to match
    if (this.preview && this.preview.parentNode) {
      this.preview.parentNode.style.height = `${newHeight}px`;
    }
  },
  
  copyToClipboard(text, message) {
    try {
      // Use the Clipboard API if available
      navigator.clipboard.writeText(text).then(() => {
        this.showCopyNotification(message || 'Copied to clipboard!');
      }).catch(err => {
        this.debug.log('Clipboard write failed:', err);
        this.fallbackCopy(text, message);
      });
    } catch (err) {
      this.debug.log('Clipboard API not available:', err);
      this.fallbackCopy(text, message);
    }
  },
  
  fallbackCopy(text, message) {
    // Fallback method using temporary textarea
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    
    try {
      const success = document.execCommand('copy');
      if (success) {
        this.showCopyNotification(message || 'Copied to clipboard!');
      } else {
        this.showCopyNotification('Copy failed. Please try manually selecting and copying the text.');
      }
    } catch (err) {
      this.debug.log('execCommand failed:', err);
      this.showCopyNotification('Copy failed. Please try manually selecting and copying the text.');
    }
    
    document.body.removeChild(textarea);
  },
  
  showCopyNotification(message) {
    // Create and show a notification
    const notification = document.createElement('div');
    notification.className = 'copy-notification';
    notification.textContent = message;
    notification.style.position = 'fixed';
    notification.style.bottom = '20px';
    notification.style.right = '20px';
    notification.style.backgroundColor = 'var(--background-color-alt)';
    notification.style.color = 'var(--text-color)';
    notification.style.padding = '10px 15px';
    notification.style.borderRadius = '4px';
    notification.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.2)';
    notification.style.zIndex = '1000';
    notification.style.opacity = '0';
    notification.style.transform = 'translateY(20px)';
    notification.style.transition = 'opacity 0.3s, transform 0.3s';
    
    document.body.appendChild(notification);
    
    // Trigger animation
    setTimeout(() => {
      notification.style.opacity = '1';
      notification.style.transform = 'translateY(0)';
    }, 10);
    
    // Remove after delay
    setTimeout(() => {
      notification.style.opacity = '0';
      notification.style.transform = 'translateY(20px)';
      
      setTimeout(() => {
        document.body.removeChild(notification);
      }, 300);
    }, 3000);
  }
};

export default DiagramEditor; 