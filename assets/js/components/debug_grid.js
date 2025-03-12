/**
 * Debug Grid Component
 * Provides a grid overlay to help align elements to the monospace grid
 */

const DebugGrid = {
  mounted() {
    // Cache DOM elements and state
    this.grid = document.querySelector('.debug-grid');
    this.enableDebug = localStorage.getItem('debugGrid') === 'true';
    this.el.checked = this.enableDebug;
    
    // Initialize debug mode
    this.setDebugMode(this.enableDebug);
    
    // Set up event listener for toggle changes
    this.el.addEventListener('change', () => {
      this.enableDebug = this.el.checked;
      localStorage.setItem('debugGrid', this.enableDebug);
      this.setDebugMode(this.enableDebug);
    });

    // Initialize mobile detection
    this.isMobile = this.detectMobileDevice();
    
    // Create mobile controls if on a mobile device
    if (this.isMobile) {
      this.createMobileControls();
    }
  },
  
  // Helper method to set debug mode
  setDebugMode(enabled) {
    document.body.classList.toggle('debug', enabled);
    this.grid.style.display = enabled ? 'block' : 'none';
    
    if (enabled) {
      this.highlightMisalignedElements();
    } else {
      document.querySelectorAll('.off-grid').forEach(el => {
        el.classList.remove('off-grid');
      });
    }

    // Show mobile controls if they exist and debug is enabled
    if (this.mobileControls && enabled) {
      this.mobileControls.style.display = 'flex';
    } else if (this.mobileControls) {
      this.mobileControls.style.display = 'none';
    }
  },
  
  // Helper method to highlight elements that might be misaligned
  highlightMisalignedElements() {
    // Cache CSS variables for performance
    const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
    const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height'));
    
    // Use requestAnimationFrame to avoid layout thrashing
    requestAnimationFrame(() => {
      document.querySelectorAll('*').forEach(el => {
        const rect = el.getBoundingClientRect();
        const isOffGridX = rect.width % charWidth !== 0;
        const isOffGridY = rect.height % lineHeight !== 0;
        
        if (isOffGridX || isOffGridY) {
          el.classList.add('off-grid');
        } else {
          el.classList.remove('off-grid');
        }
      });
    });
  },

  // Detect if running on a mobile device
  detectMobileDevice() {
    return (
      ('ontouchstart' in window) ||
      (navigator.maxTouchPoints > 0) ||
      (navigator.msMaxTouchPoints > 0) ||
      window.matchMedia("(max-width: 768px)").matches
    );
  },

  // Create mobile-friendly controls for the debug grid
  createMobileControls() {
    // Create a floating control panel for mobile
    this.mobileControls = document.createElement('div');
    this.mobileControls.className = 'debug-grid-mobile-controls';
    this.mobileControls.style.display = this.enableDebug ? 'flex' : 'none';
    
    // Add buttons with touch-friendly sizes
    const inspectBtn = this.createMobileButton('Inspect', () => this.toggleElementInspector());
    const highlightBtn = this.createMobileButton('Highlight', () => this.toggleMisalignedHighlights());
    const measureBtn = this.createMobileButton('Measure', () => this.toggleMeasurementTool());
    const closeBtn = this.createMobileButton('×', () => {
      this.enableDebug = false;
      this.el.checked = false;
      localStorage.setItem('debugGrid', 'false');
      this.setDebugMode(false);
    });
    closeBtn.className = 'debug-grid-mobile-button debug-grid-mobile-close';
    
    // Add buttons to control panel
    this.mobileControls.appendChild(inspectBtn);
    this.mobileControls.appendChild(highlightBtn);
    this.mobileControls.appendChild(measureBtn);
    this.mobileControls.appendChild(closeBtn);
    
    // Add panel to document
    document.body.appendChild(this.mobileControls);
  },

  // Helper to create a mobile-friendly button
  createMobileButton(text, onClick) {
    const button = document.createElement('button');
    button.className = 'debug-grid-mobile-button';
    button.textContent = text;
    button.addEventListener('click', onClick);
    button.addEventListener('touchstart', (e) => {
      // Add active state for touch feedback
      button.classList.add('active');
    });
    button.addEventListener('touchend', (e) => {
      // Remove active state
      button.classList.remove('active');
    });
    return button;
  },

  // Toggle element inspector mode
  toggleElementInspector() {
    if (this.inspectorMode) {
      this.disableElementInspector();
    } else {
      this.enableElementInspector();
    }
  },

  // Enable element inspector
  enableElementInspector() {
    this.inspectorMode = true;
    document.body.classList.add('debug-inspector-mode');
    
    // Add touch event handler for element inspection
    this.inspectTouchHandler = (event) => {
      event.preventDefault();
      const touch = event.touches[0];
      const element = document.elementFromPoint(touch.clientX, touch.clientY);
      if (element) {
        this.showElementInfo(element, touch.clientX, touch.clientY);
      }
    };
    
    document.addEventListener('touchstart', this.inspectTouchHandler);
    
    // Show user notification
    this.showNotification('Element inspector enabled. Tap any element to inspect it.');
  },

  // Disable element inspector
  disableElementInspector() {
    this.inspectorMode = false;
    document.body.classList.remove('debug-inspector-mode');
    document.removeEventListener('touchstart', this.inspectTouchHandler);
    
    // Remove info panel if it exists
    if (this.infoPanel) {
      document.body.removeChild(this.infoPanel);
      this.infoPanel = null;
    }
  },

  // Show element information in a panel
  showElementInfo(element, x, y) {
    // Remove existing info panel if any
    if (this.infoPanel) {
      document.body.removeChild(this.infoPanel);
    }
    
    // Create info panel
    this.infoPanel = document.createElement('div');
    this.infoPanel.className = 'debug-grid-element-info';
    
    // Get element details
    const styles = window.getComputedStyle(element);
    const rect = element.getBoundingClientRect();
    
    // Calculate positions in terms of grid
    const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
    const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height'));
    const widthInCh = (rect.width / charWidth).toFixed(2);
    const heightInLines = (rect.height / lineHeight).toFixed(2);
    
    // Create info content
    this.infoPanel.innerHTML = `
      <div class="debug-grid-element-info-header">
        <span>${element.tagName.toLowerCase()}</span>
        <button class="debug-grid-element-info-close">×</button>
      </div>
      <div class="debug-grid-element-info-content">
        <table class="element-info-table">
          <tr><td>Width:</td><td>${rect.width.toFixed(0)}px (${widthInCh} ch)</td></tr>
          <tr><td>Height:</td><td>${rect.height.toFixed(0)}px (${heightInLines} lines)</td></tr>
          <tr><td>Position:</td><td>x: ${rect.left.toFixed(0)}px, y: ${rect.top.toFixed(0)}px</td></tr>
          <tr><td>Classes:</td><td>${element.className || 'none'}</td></tr>
          <tr><td>Font:</td><td>${styles.fontFamily} (${styles.fontSize})</td></tr>
        </table>
      </div>
    `;
    
    // Position the panel
    const panelWidth = 250;
    const panelHeight = 220;
    let posX = x + 10;
    let posY = y + 10;
    
    // Ensure the panel stays within viewport
    if (posX + panelWidth > window.innerWidth) {
      posX = window.innerWidth - panelWidth - 10;
    }
    if (posY + panelHeight > window.innerHeight) {
      posY = window.innerHeight - panelHeight - 10;
    }
    
    this.infoPanel.style.left = `${posX}px`;
    this.infoPanel.style.top = `${posY}px`;
    
    // Add close button handler
    document.body.appendChild(this.infoPanel);
    this.infoPanel.querySelector('.debug-grid-element-info-close').addEventListener('click', () => {
      document.body.removeChild(this.infoPanel);
      this.infoPanel = null;
    });
  },

  // Toggle highlight of misaligned elements
  toggleMisalignedHighlights() {
    const highlightingActive = document.body.classList.toggle('debug-highlight-misaligned');
    
    if (highlightingActive) {
      this.highlightMisalignedElements();
      this.showNotification('Highlighting misaligned elements. Tap again to disable.');
    } else {
      document.querySelectorAll('.off-grid').forEach(el => {
        el.classList.remove('off-grid');
      });
      this.showNotification('Misaligned element highlighting disabled.');
    }
  },

  // Toggle measurement tool
  toggleMeasurementTool() {
    if (this.measurementActive) {
      this.disableMeasurementTool();
    } else {
      this.enableMeasurementTool();
    }
  },

  // Enable measurement tool
  enableMeasurementTool() {
    this.measurementActive = true;
    document.body.classList.add('debug-measurement-mode');
    
    // Create measurement elements if they don't exist
    if (!this.measureElement) {
      this.measureElement = document.createElement('div');
      this.measureElement.className = 'debug-grid-measure';
      document.body.appendChild(this.measureElement);
      
      this.measureInfo = document.createElement('div');
      this.measureInfo.className = 'debug-grid-measure-info';
      document.body.appendChild(this.measureInfo);
    } else {
      this.measureElement.style.display = 'block';
      this.measureInfo.style.display = 'block';
    }
    
    // Set up measurement state
    this.measuring = false;
    this.measureStartX = 0;
    this.measureStartY = 0;
    
    // Add touch event handlers
    this.measureTouchStartHandler = (event) => {
      if (!this.measuring) {
        const touch = event.touches[0];
        this.measureStartX = touch.clientX;
        this.measureStartY = touch.clientY;
        this.measuring = true;
        
        // Visualize the starting point
        this.measureElement.style.left = `${this.measureStartX}px`;
        this.measureElement.style.top = `${this.measureStartY}px`;
        this.measureElement.style.width = '0';
        this.measureElement.style.height = '0';
        this.measureElement.style.display = 'block';
        
        this.showNotification('Touch and drag to measure. Tap to finish.');
      } else {
        // Finish measurement on second tap
        this.measuring = false;
      }
      event.preventDefault();
    };
    
    this.measureTouchMoveHandler = (event) => {
      if (this.measuring) {
        const touch = event.touches[0];
        const currentX = touch.clientX;
        const currentY = touch.clientY;
        
        // Calculate dimensions
        const width = Math.abs(currentX - this.measureStartX);
        const height = Math.abs(currentY - this.measureStartY);
        const left = Math.min(currentX, this.measureStartX);
        const top = Math.min(currentY, this.measureStartY);
        
        // Update visualization
        this.measureElement.style.left = `${left}px`;
        this.measureElement.style.top = `${top}px`;
        this.measureElement.style.width = `${width}px`;
        this.measureElement.style.height = `${height}px`;
        
        // Calculate grid measurements
        const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
        const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height'));
        const widthInCh = (width / charWidth).toFixed(2);
        const heightInLines = (height / lineHeight).toFixed(2);
        
        // Update info display
        this.measureInfo.textContent = `${width.toFixed(0)}px × ${height.toFixed(0)}px (${widthInCh}ch × ${heightInLines}lines)`;
        this.measureInfo.style.left = `${left + width / 2 - 125}px`;
        this.measureInfo.style.top = `${top + height + 10}px`;
        this.measureInfo.style.display = 'block';
        
        event.preventDefault();
      }
    };
    
    this.measureTouchEndHandler = (event) => {
      if (this.measuring) {
        // Keep the measurement visible but stop active measuring
        this.measuring = false;
      }
    };
    
    document.addEventListener('touchstart', this.measureTouchStartHandler);
    document.addEventListener('touchmove', this.measureTouchMoveHandler);
    document.addEventListener('touchend', this.measureTouchEndHandler);
    
    this.showNotification('Measurement tool enabled. Tap to set start point, then drag or tap again.');
  },

  // Disable measurement tool
  disableMeasurementTool() {
    this.measurementActive = false;
    document.body.classList.remove('debug-measurement-mode');
    
    // Hide measurement elements
    if (this.measureElement) {
      this.measureElement.style.display = 'none';
      this.measureInfo.style.display = 'none';
    }
    
    // Remove event handlers
    document.removeEventListener('touchstart', this.measureTouchStartHandler);
    document.removeEventListener('touchmove', this.measureTouchMoveHandler);
    document.removeEventListener('touchend', this.measureTouchEndHandler);
    
    this.showNotification('Measurement tool disabled.');
  },

  // Helper method to show notifications
  showNotification(message) {
    if (this.notification) {
      document.body.removeChild(this.notification);
    }
    
    this.notification = document.createElement('div');
    this.notification.className = 'debug-grid-notification';
    this.notification.textContent = message;
    document.body.appendChild(this.notification);
    
    // Auto-hide notification after 3 seconds
    setTimeout(() => {
      if (this.notification) {
        this.notification.classList.add('hiding');
        setTimeout(() => {
          if (this.notification) {
            document.body.removeChild(this.notification);
            this.notification = null;
          }
        }, 500);
      }
    }, 3000);
  }
};

export default DebugGrid; 