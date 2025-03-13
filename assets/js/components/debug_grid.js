/**
 * Debug Grid Component
 * Provides a grid overlay to help align elements to the monospace grid
 * 
 * This component has been refactored to:
 * 1. Use the EventManager for centralized event handling
 * 2. Implement DOM Cleanup Protocol for proper teardown
 * 3. Use CSS variables for theming and z-index management
 * 4. Isolate functionality to prevent interference with other components
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

const DebugGrid = {
  mounted() {
    // Generate a unique component ID
    this.componentId = `debug-grid-${Date.now()}`;
    
    // Initialize event management and DOM cleanup
    this.events = EventManager.registerComponent(this.componentId);
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Cache DOM elements and state
    this.grid = document.querySelector('.debug-grid');
    this.enableDebug = localStorage.getItem('debugGrid') === 'true';
    this.el.checked = this.enableDebug;
    
    // Store references to dynamically created elements for later cleanup
    this.dynamicElements = {};
    
    // Load settings from localStorage (with defaults)
    this.loadSettings();
    
    // Initialize debug mode
    this.setDebugMode(this.enableDebug);
    
    // Set up event listener for toggle changes using event manager
    this.events.addEventListener(this.el, 'change', () => {
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
    
    // Clean up event listeners when component is unmounted
    this.handleBeforeUnmount();
  },
  
  /**
   * Load settings from localStorage with defaults
   */
  loadSettings() {
    try {
      const savedSettings = localStorage.getItem('debugGridSettings');
      if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        this.gridDensity = settings.gridDensity || 'character';
        this.measurementMode = settings.measurementMode || 'pixels';
        this.gridColor = settings.gridColor || '#0000ff';
        this.gridOpacity = settings.gridOpacity || 0.1;
        this.measurementOptions = settings.measurementOptions || {
          showPixels: true,
          showCharacters: true,
          showLines: true
        };
      } else {
        // Default settings
        this.gridDensity = 'character';
        this.measurementMode = 'pixels';
        this.gridColor = '#0000ff';
        this.gridOpacity = 0.1;
        this.measurementOptions = {
          showPixels: true,
          showCharacters: true,
          showLines: true
        };
      }
    } catch (e) {
      console.warn('Failed to load debug grid settings:', e);
      // Use defaults on error
      this.gridDensity = 'character';
      this.measurementMode = 'pixels';
      this.gridColor = '#0000ff';
      this.gridOpacity = 0.1;
      this.measurementOptions = {
        showPixels: true,
        showCharacters: true,
        showLines: true
      };
    }
  },
  
  /**
   * Helper method to set debug mode
   */
  setDebugMode(enabled) {
    document.body.classList.toggle('debug', enabled);
    this.grid.style.display = enabled ? 'block' : 'none';
    
    if (enabled) {
      this.highlightMisalignedElements();
    } else {
      document.querySelectorAll('.off-grid').forEach(el => {
        el.classList.remove('off-grid');
        el.removeAttribute('data-grid-info');
      });
      
      // Ensure inspector and measurement tool are disabled
      this.disableElementInspector();
      this.disableMeasurementTool();
    }

    // Show mobile controls if they exist and debug is enabled
    if (this.dynamicElements.mobileControls) {
      this.dynamicElements.mobileControls.style.display = enabled ? 'flex' : 'none';
    }
  },
  
  /**
   * Highlight elements that are misaligned with the monospace grid
   */
  highlightMisalignedElements() {
    if (!this.enableDebug) return;
    
    // Clear previous highlights
    document.querySelectorAll('.off-grid').forEach(el => {
      el.classList.remove('off-grid');
      el.removeAttribute('data-grid-info');
    });
    
    // Get monospace font metrics
    const root = document.documentElement;
    const computedStyle = getComputedStyle(root);
    const fontSizeInPx = parseFloat(computedStyle.fontSize);
    const chWidthInPx = fontSizeInPx * 0.6; // Approximation for monospace
    const lineHeightInRem = parseFloat(computedStyle.getPropertyValue('--line-height') || '1.5');
    const lineHeightInPx = lineHeightInRem * fontSizeInPx;
    
    // Select elements to check (excluding debug UI elements)
    const elements = Array.from(document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, div, span, pre, code, li, ul, ol'))
      .filter(el => !el.closest('.debug-grid-settings, .debug-grid-mobile-controls, .debug-grid-element-info'));
    
    elements.forEach(el => {
      const rect = el.getBoundingClientRect();
      const { left, top, width, height } = rect;
      
      // Check alignment with ch grid
      const isLeftAligned = Math.abs(left % chWidthInPx) < 0.5;
      const isWidthAligned = Math.abs(width % chWidthInPx) < 0.5;
      
      // Check alignment with line height grid
      const isTopAligned = Math.abs(top % lineHeightInPx) < 0.5;
      const isHeightAligned = Math.abs(height % lineHeightInPx) < 0.5;
      
      // If any dimension is misaligned, mark the element
      if (!isLeftAligned || !isWidthAligned || !isTopAligned || !isHeightAligned) {
        el.classList.add('off-grid');
        
        // Add measurement info as data attribute
        const info = `Position: ${Math.round(left)}px × ${Math.round(top)}px, Size: ${Math.round(width)}px × ${Math.round(height)}px`;
        el.setAttribute('data-grid-info', info);
      }
    });
  },
  
  /**
   * Detect if the current device is mobile
   */
  detectMobileDevice() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) || window.innerWidth < 768;
  },
  
  /**
   * Create mobile-friendly controls for debug grid
   */
  createMobileControls() {
    // Create container
    const controlsContainer = DOMCleanup.createElement('div', {
      className: 'debug-grid-mobile-controls z-debug-controls',
      style: {
        display: this.enableDebug ? 'flex' : 'none'
      }
    });
    
    // Create buttons
    const inspectorButton = this.createMobileButton('Inspect', () => this.toggleElementInspector());
    const measureButton = this.createMobileButton('Measure', () => this.toggleMeasurementTool());
    const highlightButton = this.createMobileButton('Highlight', () => this.toggleMisalignedHighlights());
    
    // Add close button
    const closeButton = DOMCleanup.createElement('button', {
      className: 'debug-grid-mobile-button debug-grid-mobile-close',
      onclick: () => this.setDebugMode(false)
    }, '✕');
    
    // Append all buttons to container
    controlsContainer.appendChild(inspectorButton);
    controlsContainer.appendChild(measureButton);
    controlsContainer.appendChild(highlightButton);
    controlsContainer.appendChild(closeButton);
    
    // Add to DOM
    document.body.appendChild(controlsContainer);
    
    // Store for later cleanup
    this.dynamicElements.mobileControls = controlsContainer;
    this.cleanup.registerElement(controlsContainer);
  },
  
  /**
   * Create a mobile-friendly button
   */
  createMobileButton(text, onClick) {
    const button = DOMCleanup.createElement('button', {
      className: 'debug-grid-mobile-button',
    }, text);
    
    // Register click event with event manager
    this.events.addEventListener(button, 'click', onClick);
    
    return button;
  },
  
  /**
   * Toggle element inspector mode
   */
  toggleElementInspector() {
    if (this.inspectorMode) {
      this.disableElementInspector();
    } else {
      this.enableElementInspector();
    }
  },
  
  /**
   * Enable element inspector mode
   */
  enableElementInspector() {
    if (this.inspectorMode) return;
    
    this.inspectorMode = true;
    
    // Show notification
    this.showNotification('Element inspector enabled. Click on any element to inspect.');
    
    // Add click event listener to document
    const clickHandler = (e) => {
      // Prevent default behavior
      e.preventDefault();
      
      // Get clicked element
      const element = e.target;
      
      // Don't inspect debug UI elements
      if (element.closest('.debug-grid-settings, .debug-grid-mobile-controls, .debug-grid-element-info')) {
        return;
      }
      
      // Show element info
      this.showElementInfo(element, e.clientX, e.clientY);
    };
    
    // Register with event manager for proper cleanup
    this.events.addEventListener(document, 'click', clickHandler);
    
    // Store handler reference for cleanup
    this.inspectorClickHandler = clickHandler;
  },
  
  /**
   * Disable element inspector mode
   */
  disableElementInspector() {
    if (!this.inspectorMode) return;
    
    this.inspectorMode = false;
    
    // Remove click event listener
    if (this.inspectorClickHandler) {
      document.removeEventListener('click', this.inspectorClickHandler);
      this.inspectorClickHandler = null;
    }
    
    // Remove any existing info panel
    if (this.dynamicElements.infoPanel) {
      if (this.dynamicElements.infoPanel.parentNode) {
        this.dynamicElements.infoPanel.parentNode.removeChild(this.dynamicElements.infoPanel);
      }
      this.dynamicElements.infoPanel = null;
    }
  },
  
  /**
   * Show information about an element
   */
  showElementInfo(element, x, y) {
    // Remove existing info panel if any
    if (this.dynamicElements.infoPanel) {
      if (this.dynamicElements.infoPanel.parentNode) {
        this.dynamicElements.infoPanel.parentNode.removeChild(this.dynamicElements.infoPanel);
      }
      this.dynamicElements.infoPanel = null;
    }
    
    // Get element info
    const rect = element.getBoundingClientRect();
    const computedStyle = getComputedStyle(element);
    
    // Create info panel using DOM Cleanup utility
    const infoPanel = DOMCleanup.createElement('div', {
      className: 'debug-grid-element-info z-debug-panel'
    });
    
    // Create header
    const header = DOMCleanup.createElement('div', {
      className: 'debug-grid-element-info-header'
    });
    
    // Add element tag name
    const tagName = DOMCleanup.createElement('span', {}, element.tagName.toLowerCase());
    header.appendChild(tagName);
    
    // Add close button
    const closeButton = DOMCleanup.createElement('button', {
      className: 'debug-grid-element-info-close'
    }, '×');
    this.events.addEventListener(closeButton, 'click', () => {
      if (infoPanel.parentNode) {
        infoPanel.parentNode.removeChild(infoPanel);
      }
      this.dynamicElements.infoPanel = null;
    });
    header.appendChild(closeButton);
    
    // Add content
    const content = DOMCleanup.createElement('div', {
      className: 'debug-grid-element-info-content'
    });
    
    // Position info
    content.innerHTML = `
      <h4>Position & Size</h4>
      <p>Left: ${Math.round(rect.left)}px (${(rect.left / parseFloat(computedStyle.fontSize) * 0.6).toFixed(1)}ch)</p>
      <p>Top: ${Math.round(rect.top)}px (${(rect.top / (parseFloat(computedStyle.fontSize) * parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height') || 1.5))).toFixed(1)}em)</p>
      <p>Width: ${Math.round(rect.width)}px (${(rect.width / parseFloat(computedStyle.fontSize) * 0.6).toFixed(1)}ch)</p>
      <p>Height: ${Math.round(rect.height)}px (${(rect.height / (parseFloat(computedStyle.fontSize) * parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height') || 1.5))).toFixed(1)}em)</p>
      
      <h4>Grid Alignment</h4>
      <p>Left aligned: ${Math.abs(rect.left % (parseFloat(computedStyle.fontSize) * 0.6)) < 0.5 ? 'Yes ✓' : 'No ✗'}</p>
      <p>Top aligned: ${Math.abs(rect.top % (parseFloat(computedStyle.fontSize) * parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height') || 1.5))) < 0.5 ? 'Yes ✓' : 'No ✗'}</p>
      <p>Width aligned: ${Math.abs(rect.width % (parseFloat(computedStyle.fontSize) * 0.6)) < 0.5 ? 'Yes ✓' : 'No ✗'}</p>
      <p>Height aligned: ${Math.abs(rect.height % (parseFloat(computedStyle.fontSize) * parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height') || 1.5))) < 0.5 ? 'Yes ✓' : 'No ✗'}</p>
    `;
    
    // Add to DOM
    infoPanel.appendChild(header);
    infoPanel.appendChild(content);
    
    // Position the panel
    let posX = x + 10;
    let posY = y + 10;
    
    // Ensure panel stays within viewport
    const panelWidth = 250;
    const panelHeight = 300;
    
    if (posX + panelWidth > window.innerWidth) {
      posX = window.innerWidth - panelWidth - 10;
    }
    
    if (posY + panelHeight > window.innerHeight) {
      posY = window.innerHeight - panelHeight - 10;
    }
    
    infoPanel.style.left = `${posX}px`;
    infoPanel.style.top = `${posY}px`;
    
    document.body.appendChild(infoPanel);
    
    // Store for later cleanup
    this.dynamicElements.infoPanel = infoPanel;
    this.cleanup.registerElement(infoPanel);
  },
  
  /**
   * Toggle visibility of misaligned elements
   */
  toggleMisalignedHighlights() {
    if (document.querySelectorAll('.off-grid').length > 0) {
      // Hide all highlights
      document.querySelectorAll('.off-grid').forEach(el => {
        el.classList.remove('off-grid');
        el.removeAttribute('data-grid-info');
      });
      this.showNotification('Grid alignment highlights hidden');
    } else {
      // Show all highlights
      this.highlightMisalignedElements();
      this.showNotification('Showing elements misaligned with the grid');
    }
  },
  
  /**
   * Toggle measurement tool
   */
  toggleMeasurementTool() {
    if (this.measurementMode) {
      this.disableMeasurementTool();
    } else {
      this.enableMeasurementTool();
    }
  },
  
  /**
   * Enable measurement tool
   */
  enableMeasurementTool() {
    if (this.measurementMode) return;
    
    this.measurementMode = true;
    
    // Show notification
    this.showNotification('Measurement tool enabled. Click and drag to measure.');
    
    // Create measurement element
    const measureEl = DOMCleanup.createElement('div', {
      className: 'debug-grid-measure z-debug-overlay',
      style: {
        display: 'none'
      }
    });
    
    // Create info display
    const infoEl = DOMCleanup.createElement('div', {
      className: 'debug-grid-measure-info z-debug-panel',
      style: {
        display: 'none'
      }
    });
    
    // Add to DOM
    document.body.appendChild(measureEl);
    document.body.appendChild(infoEl);
    
    // Store for later cleanup
    this.dynamicElements.measureElement = measureEl;
    this.dynamicElements.measureInfo = infoEl;
    this.cleanup.registerElement(measureEl);
    this.cleanup.registerElement(infoEl);
    
    // Mouse event data
    let isMouseDown = false;
    let startX = 0;
    let startY = 0;
    let currentX = 0;
    let currentY = 0;
    
    // Mouse down handler
    const mouseDownHandler = (e) => {
      // Don't measure on debug UI elements
      if (e.target.closest('.debug-grid-settings, .debug-grid-mobile-controls, .debug-grid-element-info, .debug-grid-measure, .debug-grid-measure-info')) {
        return;
      }
      
      isMouseDown = true;
      startX = e.clientX;
      startY = e.clientY;
      
      // Show measurement element
      measureEl.style.display = 'block';
      measureEl.style.left = `${startX}px`;
      measureEl.style.top = `${startY}px`;
      measureEl.style.width = '0px';
      measureEl.style.height = '0px';
      
      // Show info element
      infoEl.style.display = 'block';
    };
    
    // Mouse move handler
    const mouseMoveHandler = (e) => {
      if (!isMouseDown) return;
      
      currentX = e.clientX;
      currentY = e.clientY;
      
      // Calculate dimensions
      const left = Math.min(startX, currentX);
      const top = Math.min(startY, currentY);
      const width = Math.abs(currentX - startX);
      const height = Math.abs(currentY - startY);
      
      // Update measurement element
      measureEl.style.left = `${left}px`;
      measureEl.style.top = `${top}px`;
      measureEl.style.width = `${width}px`;
      measureEl.style.height = `${height}px`;
      
      // Get monospace metrics
      const fontSizeInPx = parseFloat(getComputedStyle(document.documentElement).fontSize);
      const chWidth = fontSizeInPx * 0.6; // Approximation for monospace
      const lineHeightInRem = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height') || '1.5');
      const lineHeight = lineHeightInRem * fontSizeInPx;
      
      // Update info display
      infoEl.innerHTML = `
        ${width.toFixed(0)}px × ${height.toFixed(0)}px<br>
        ${(width / chWidth).toFixed(1)}ch × ${(height / lineHeight).toFixed(1)}em
      `;
      
      // Position info display
      infoEl.style.left = `${left + (width / 2) - (infoEl.offsetWidth / 2)}px`;
      infoEl.style.top = `${top + height + 10}px`;
    };
    
    // Mouse up handler
    const mouseUpHandler = () => {
      isMouseDown = false;
    };
    
    // Register event listeners with event manager
    this.events.addEventListener(document, 'mousedown', mouseDownHandler);
    this.events.addEventListener(document, 'mousemove', mouseMoveHandler);
    this.events.addEventListener(document, 'mouseup', mouseUpHandler);
    
    // Store handlers for cleanup
    this.measurementHandlers = {
      mouseDown: mouseDownHandler,
      mouseMove: mouseMoveHandler,
      mouseUp: mouseUpHandler
    };
  },
  
  /**
   * Disable measurement tool
   */
  disableMeasurementTool() {
    if (!this.measurementMode) return;
    
    this.measurementMode = false;
    
    // Remove event listeners
    if (this.measurementHandlers) {
      document.removeEventListener('mousedown', this.measurementHandlers.mouseDown);
      document.removeEventListener('mousemove', this.measurementHandlers.mouseMove);
      document.removeEventListener('mouseup', this.measurementHandlers.mouseUp);
      this.measurementHandlers = null;
    }
    
    // Remove measurement elements
    if (this.dynamicElements.measureElement) {
      if (this.dynamicElements.measureElement.parentNode) {
        this.dynamicElements.measureElement.parentNode.removeChild(this.dynamicElements.measureElement);
      }
      this.dynamicElements.measureElement = null;
    }
    
    if (this.dynamicElements.measureInfo) {
      if (this.dynamicElements.measureInfo.parentNode) {
        this.dynamicElements.measureInfo.parentNode.removeChild(this.dynamicElements.measureInfo);
      }
      this.dynamicElements.measureInfo = null;
    }
  },
  
  /**
   * Show a notification message
   */
  showNotification(message) {
    // Remove existing notification
    if (this.dynamicElements.notification) {
      if (this.dynamicElements.notification.parentNode) {
        this.dynamicElements.notification.parentNode.removeChild(this.dynamicElements.notification);
      }
      this.dynamicElements.notification = null;
    }
    
    // Create notification element
    const notification = DOMCleanup.createElement('div', {
      className: 'debug-grid-notification z-debug-panel'
    }, message);
    
    // Add to DOM
    document.body.appendChild(notification);
    
    // Store for later cleanup
    this.dynamicElements.notification = notification;
    this.cleanup.registerElement(notification);
    
    // Auto-hide after delay
    const notificationTimeout = setTimeout(() => {
      notification.classList.add('hiding');
      
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
        this.dynamicElements.notification = null;
      }, 300);
    }, 3000);
    
    // Register timeout for cleanup
    this.cleanup.registerTimeout(notificationTimeout);
  },
  
  /**
   * Handle component cleanup before unmount
   */
  handleBeforeUnmount() {
    // Add event listener for beforeunload to clean up resources
    window.addEventListener('beforeunload', this.cleanupResources.bind(this));
    
    // For Phoenix LiveView hooks, this should be called in the destroyed callback
    // if available in your hook implementation
  },
  
  /**
   * Clean up resources
   */
  cleanupResources() {
    // Disable features that might have active event listeners
    this.disableElementInspector();
    this.disableMeasurementTool();
    
    // Use our cleanup utility to clean up any remaining resources
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.componentId) {
      EventManager.unregisterComponent(this.componentId);
    }
  },
  
  destroyed() {
    // This is called when a Phoenix LiveView hook is destroyed
    this.cleanupResources();
  }
};

export default DebugGrid; 