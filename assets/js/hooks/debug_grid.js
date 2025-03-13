/**
 * Debug Grid Hook
 * Shows a visual grid for monospace layout debugging
 * Uses CSS grid visualizer to show character and line boundaries
 */
const DebugGrid = {
  mounted() {
    this.bodyElement = document.body;
    this.debugEnabled = false;
    this.gridDensity = 'character'; // Options: 'character', 'word', 'paragraph'
    
    // Initialize measurement tools
    this.measurementEnabled = false;
    this.measurementOrigin = null;
    this.measurementTarget = null;
    this.measurementElement = null;
    this.measurementDisplay = null;
    this.measurementMode = 'distance'; // Options: 'distance', 'alignment', 'element'
    
    // Initialize tutorial state
    this.tutorialActive = false;
    this.tutorialStep = 0;
    this.tutorialSeen = localStorage.getItem('debugGridTutorialSeen') === 'true';
    
    // Clean up any existing tutorials from previous page load
    this.cleanupExistingTutorials();
    
    // Bind methods to this instance to ensure proper context
    this.toggleDebugGrid = this.toggleDebugGrid.bind(this);
    this.handleKeyPress = this.handleKeyPress.bind(this);
    this.updateGridSizing = this.updateGridSizing.bind(this);
    this.toggleMeasurementTool = this.toggleMeasurementTool.bind(this);
    this.handleMeasurementClick = this.handleMeasurementClick.bind(this);
    this.handleMeasurementMove = this.handleMeasurementMove.bind(this);
    this.handleTouchStart = this.handleTouchStart.bind(this);
    this.handleTouchMove = this.handleTouchMove.bind(this);
    this.handleTouchEnd = this.handleTouchEnd.bind(this);
    this.showDebugNotification = this.showDebugNotification.bind(this);
    this.highlightMisalignedElements = this.highlightMisalignedElements.bind(this);
    this.cycleMeasurementMode = this.cycleMeasurementMode.bind(this);
    this.updateMeasurementDisplay = this.updateMeasurementDisplay.bind(this);
    this.showTutorial = this.showTutorial.bind(this);
    this.hideTutorial = this.hideTutorial.bind(this);
    this.nextTutorialStep = this.nextTutorialStep.bind(this);
    this.prevTutorialStep = this.prevTutorialStep.bind(this);
    this.goToTutorialStep = this.goToTutorialStep.bind(this);
    
    // Store reference globally so it can be used by the toggle
    window.debugGrid = this;
    
    // Add event listener to handle debug key press
    document.addEventListener('keydown', this.handleKeyPress);
    
    // Handle window resize events to recalculate grid size
    window.addEventListener('phx:resize', this.updateGridSizing);
    
    // Create settings panel
    this.createSettingsPanel();
    
    this.updateGridSizing();
  },
  
  /**
   * Create a settings panel for debug grid configuration
   */
  createSettingsPanel() {
    this.settingsPanel = document.createElement('div');
    this.settingsPanel.id = 'debug-grid-settings';
    this.settingsPanel.className = 'debug-grid-settings';
    
    // Ensure clicks work on the settings panel
    this.settingsPanel.style.pointerEvents = 'auto';
    
    // Add mobile class if touch is available
    if ('ontouchstart' in window) {
      this.settingsPanel.classList.add('touch-friendly');
    }
    
    this.settingsPanel.innerHTML = `
      <div class="debug-grid-settings-header">
        <h3>Debug Grid Settings</h3>
        <button class="debug-grid-close" aria-label="Close settings panel">×</button>
      </div>
      <div class="debug-grid-settings-content">
        <div class="debug-grid-setting">
          <label for="grid-density">Grid Density:</label>
          <select id="grid-density" class="touch-target">
            <option value="character">Character (1ch)</option>
            <option value="word">Word (5ch)</option>
            <option value="paragraph">Paragraph (10ch)</option>
          </select>
        </div>
        <div class="debug-grid-setting">
          <label for="grid-color">Grid Color:</label>
          <input type="color" id="grid-color" value="#0000ff" class="touch-target">
        </div>
        <div class="debug-grid-setting">
          <label for="grid-opacity">Grid Opacity:</label>
          <input type="range" id="grid-opacity" min="0.05" max="0.3" step="0.05" value="0.1" class="touch-target">
          <span id="grid-opacity-value">0.1</span>
        </div>
        <div class="debug-grid-setting">
          <label for="measurement-mode">Measurement Mode:</label>
          <select id="measurement-mode" class="touch-target">
            <option value="distance">Distance (Point to Point)</option>
            <option value="alignment">Alignment (Grid Offset)</option>
            <option value="element">Element (Size & Position)</option>
          </select>
        </div>
        <div class="debug-grid-setting">
          <button id="toggle-measurements" class="touch-target">Toggle Measurement Tool</button>
        </div>
        <div class="debug-grid-setting measurement-options" style="display: none;">
          <label>Measurement Display:</label>
          <div class="measurement-display-options">
            <label class="touch-checkbox"><input type="checkbox" checked name="show-pixels" /> <span>Pixels</span></label>
            <label class="touch-checkbox"><input type="checkbox" checked name="show-characters" /> <span>Characters</span></label>
            <label class="touch-checkbox"><input type="checkbox" checked name="show-lines" /> <span>Lines</span></label>
          </div>
        </div>
        <div class="debug-grid-setting">
          <button id="toggle-shortcuts" class="touch-target">Show Keyboard Shortcuts</button>
        </div>
        <div id="shortcuts-section" class="debug-grid-keyboard-shortcuts" style="display: none;">
          <h4>Keyboard Shortcuts</h4>
          <p class="shortcut-description">The following keyboard shortcuts are available for controlling the debug grid:</p>
          
          <h5>Grid Controls</h5>
          <ul>
            <li><kbd>Alt</kbd> + <kbd>G</kbd> - Toggle Debug Grid On/Off</li>
            <li><kbd>Alt</kbd> + <kbd>S</kbd> - Show/Hide Settings Panel (when grid is enabled)</li>
          </ul>
          
          <h5>Grid Density</h5>
          <ul>
            <li><kbd>Alt</kbd> + <kbd>1</kbd> - Character Mode (1ch grid)</li>
            <li><kbd>Alt</kbd> + <kbd>2</kbd> - Word Mode (5ch grid)</li>
            <li><kbd>Alt</kbd> + <kbd>3</kbd> - Paragraph Mode (10ch grid)</li>
          </ul>
          
          <h5>Measurement Tools</h5>
          <ul>
            <li><kbd>Alt</kbd> + <kbd>M</kbd> - Toggle Measurement Tool On/Off</li>
            <li><kbd>Alt</kbd> + <kbd>C</kbd> - Cycle Through Measurement Modes (when measurement tool is active)</li>
            <li><kbd>Esc</kbd> - Cancel Current Measurement (when measurement is in progress)</li>
          </ul>
          
          <p class="shortcut-tip">Tip: After enabling the grid with <kbd>Alt</kbd> + <kbd>G</kbd>, you can use <kbd>Alt</kbd> + <kbd>M</kbd> to start measuring, and <kbd>Esc</kbd> to cancel.</p>
        </div>
        <div class="debug-grid-setting">
          <button id="show-tutorial" class="touch-target">Show Tutorial</button>
        </div>
        <div class="touch-instructions" style="display: none;">
          <h4>Touch Instructions</h4>
          <ul>
            <li><strong>Tap once</strong> to set measurement origin</li>
            <li><strong>Tap again</strong> to complete measurement</li>
            <li><strong>Drag</strong> to see real-time measurements</li>
            <li><strong>Two-finger tap</strong> to cancel measurement</li>
          </ul>
        </div>
      </div>
    `;
    
    // Show touch instructions only on touch devices
    if ('ontouchstart' in window) {
      const touchInstructions = this.settingsPanel.querySelector('.touch-instructions');
      if (touchInstructions) {
        touchInstructions.style.display = 'block';
      }
    }
    
    document.body.appendChild(this.settingsPanel);
    
    // Add event listeners
    this.settingsPanel.querySelector('.debug-grid-close').addEventListener('click', () => {
      this.settingsPanel.style.display = 'none';
    });
    
    // Toggle keyboard shortcuts section
    const toggleShortcutsButton = this.settingsPanel.querySelector('#toggle-shortcuts');
    const shortcutsSection = this.settingsPanel.querySelector('#shortcuts-section');
    
    toggleShortcutsButton.addEventListener('click', () => {
      const isVisible = shortcutsSection.style.display !== 'none';
      shortcutsSection.style.display = isVisible ? 'none' : 'block';
      toggleShortcutsButton.textContent = isVisible ? 'Show Keyboard Shortcuts' : 'Hide Keyboard Shortcuts';
    });
    
    // Grid density change
    const densitySelect = this.settingsPanel.querySelector('#grid-density');
    densitySelect.addEventListener('change', () => {
      this.gridDensity = densitySelect.value;
      this.updateGridSizing();
    });
    
    // Grid color change
    const colorInput = this.settingsPanel.querySelector('#grid-color');
    colorInput.addEventListener('change', () => {
      const color = colorInput.value;
      const opacity = this.settingsPanel.querySelector('#grid-opacity').value;
      const rgbaColor = this.hexToRgba(color, opacity);
      document.documentElement.style.setProperty('--debug-grid-color', rgbaColor);
    });
    
    // Grid opacity change
    const opacityInput = this.settingsPanel.querySelector('#grid-opacity');
    const opacityValue = this.settingsPanel.querySelector('#grid-opacity-value');
    opacityInput.addEventListener('input', () => {
      opacityValue.textContent = opacityInput.value;
      const color = this.settingsPanel.querySelector('#grid-color').value;
      const rgbaColor = this.hexToRgba(color, opacityInput.value);
      document.documentElement.style.setProperty('--debug-grid-color', rgbaColor);
    });
    
    // Measurement mode change
    const modeSelect = this.settingsPanel.querySelector('#measurement-mode');
    modeSelect.addEventListener('change', () => {
      this.measurementMode = modeSelect.value;
      
      if (this.measurementEnabled) {
        // Reset measurement state when changing modes
        this.measurementOrigin = null;
        this.measurementTarget = null;
        if (this.measurementElement) {
          this.measurementElement.style.display = 'none';
        }
        this.showDebugNotification(`Measurement mode: ${this.measurementMode}. Click to begin measuring.`);
      }
    });
    
    // Toggle measurement tool
    this.settingsPanel.querySelector('#toggle-measurements').addEventListener('click', () => {
      this.toggleMeasurementTool();
    });
    
    // Show measurement options when measurement tool is enabled
    this.settingsPanel.querySelectorAll('.measurement-display-options input').forEach(input => {
      input.addEventListener('change', this.updateMeasurementDisplay);
    });

    // Add event listener for the tutorial button
    const showTutorialButton = this.settingsPanel.querySelector('#show-tutorial');
    showTutorialButton.addEventListener('click', () => {
      this.showTutorial();
    });
  },
  
  /**
   * Convert hex color to rgba
   */
  hexToRgba(hex, opacity) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${opacity})`;
  },
  
  /**
   * Handle keyboard shortcut to toggle debug grid
   * Uses Alt+G as the keyboard shortcut
   */
  handleKeyPress(event) {
    // Check for keyboard shortcuts
    if (event.altKey) {
      switch (event.key.toLowerCase()) {
        case 'g':
          // Toggle debug grid
          this.toggleDebugGrid();
          event.preventDefault();
          break;
        case 'm':
          // Toggle measurement tool
          this.toggleMeasurementTool();
          event.preventDefault();
          break;
        case 'c':
          // Cycle measurement mode
          if (this.measurementEnabled) {
            this.cycleMeasurementMode();
            event.preventDefault();
          }
          break;
        case 's':
          if (this.debugEnabled) {
            this.settingsPanel.style.display = this.settingsPanel.style.display === 'none' ? 'block' : 'none';
            event.preventDefault();
          }
          break;
        case '1':
          if (this.debugEnabled) {
            this.gridDensity = 'character';
            this.updateGridSizing();
            this.showDebugNotification('Grid density set to Character mode');
            event.preventDefault();
          }
          break;
        case '2':
          if (this.debugEnabled) {
            this.gridDensity = 'word';
            this.updateGridSizing();
            this.showDebugNotification('Grid density set to Word mode');
            event.preventDefault();
          }
          break;
        case '3':
          if (this.debugEnabled) {
            this.gridDensity = 'paragraph';
            this.updateGridSizing();
            this.showDebugNotification('Grid density set to Paragraph mode');
            event.preventDefault();
          }
          break;
      }
    } else if (event.key === 'Escape') {
      // Cancel current measurement with Escape key
      if (this.measurementEnabled && this.measurementOrigin) {
        this.measurementOrigin = null;
        this.measurementTarget = null;
        
        // Update the visual state
        if (this.measurementElement) {
          this.measurementElement.style.display = 'none';
        }
        
        if (this.measurementDisplay) {
          this.measurementDisplay.style.display = 'none';
        }
        
        this.showDebugNotification('Measurement canceled.');
        event.preventDefault();
      }
    }
  },
  
  /**
   * Toggle the debug grid visibility
   */
  toggleDebugGrid() {
    this.debugEnabled = !this.debugEnabled;
    
    if (this.debugEnabled) {
      // Create grid overlay if it doesn't exist
      if (!this.gridOverlay) {
        this.gridOverlay = document.createElement('div');
        this.gridOverlay.id = 'debug-grid-overlay';
        document.body.appendChild(this.gridOverlay);
      }
      
      // Create settings panel if it doesn't exist
      if (!this.settingsPanel) {
        this.createSettingsPanel();
        
        // Add event listeners to settings controls
        const gridDensitySelect = document.querySelector('#grid-density');
        gridDensitySelect.addEventListener('change', (e) => {
          this.gridDensity = e.target.value;
          this.updateGridSizing();
          this.saveGridSettings();
        });
        
        const gridColorInput = document.querySelector('#grid-color');
        gridColorInput.addEventListener('change', (e) => {
          this.updateGridSizing();
          this.saveGridSettings();
        });
        
        const gridOpacityInput = document.querySelector('#grid-opacity');
        gridOpacityInput.addEventListener('input', (e) => {
          document.querySelector('#grid-opacity-value').textContent = e.target.value;
          this.updateGridSizing();
          this.saveGridSettings();
        });
        
        const measurementModeSelect = document.querySelector('#measurement-mode');
        measurementModeSelect.addEventListener('change', (e) => {
          this.measurementMode = e.target.value;
          this.saveGridSettings();
        });
        
        // Add event listeners to measurement display options
        const measurementOptions = document.querySelectorAll('.measurement-display-options input');
        measurementOptions.forEach(option => {
          option.addEventListener('change', () => {
            this.saveGridSettings();
          });
        });
        
        // Add event listener to toggle measurements button
        const toggleMeasurementsButton = document.querySelector('#toggle-measurements');
        toggleMeasurementsButton.addEventListener('click', this.toggleMeasurementTool);
        
        // Add event listener to close button
        const closeButton = document.querySelector('.debug-grid-close');
        closeButton.addEventListener('click', () => {
          this.settingsPanel.style.display = 'none';
        });
      }
      
      // Clean up any existing tutorials
      this.cleanupExistingTutorials();
      
      // Show the grid overlay
      this.gridOverlay.style.display = 'block';
      
      // Update grid based on current settings
      this.updateGridSizing();
      
      // Position and show the settings panel
      this.settingsPanel.style.position = 'fixed';
      this.settingsPanel.style.top = '20px';
      this.settingsPanel.style.right = '20px';
      this.settingsPanel.style.zIndex = '9995';
      this.settingsPanel.style.display = 'block';
      
      // Restore settings if available
      this.restoreGridSettings();
      
      // Show tutorial for first-time users
      if (!this.tutorialSeen) {
        // Pre-initialize the tutorial element with proper positioning
        if (!this.tutorialElement) {
          this.tutorialElement = document.createElement('div');
          this.tutorialElement.className = 'debug-grid-tutorial';
          this.tutorialElement.style.position = 'fixed';
          this.tutorialElement.style.top = '0';
          this.tutorialElement.style.left = '0';
          this.tutorialElement.style.right = '0';
          this.tutorialElement.style.bottom = '0';
          this.tutorialElement.style.zIndex = '10000';
          this.tutorialElement.style.display = 'none';
          this.tutorialElement.style.justifyContent = 'center';
          this.tutorialElement.style.alignItems = 'center';
          document.body.appendChild(this.tutorialElement);
        }
        
        // Ensure we're scrolled to the top of the page
        window.scrollTo(0, 0);
        
        setTimeout(() => {
          this.showTutorial();
          this.tutorialSeen = true;
          localStorage.setItem('debugGridTutorialSeen', 'true');
        }, 500);
      }
      
      // Show debug notification
      this.showDebugNotification('Debug grid enabled. Press Alt+G to toggle.');
    } else {
      // Hide the grid overlay
      if (this.gridOverlay) {
        this.gridOverlay.style.display = 'none';
      }
      
      // Hide the settings panel
      if (this.settingsPanel) {
        this.settingsPanel.style.display = 'none';
      }
      
      // Disable measurement tool if active
      if (this.measurementEnabled) {
        this.toggleMeasurementTool();
      }
      
      // Clean up any tutorials
      if (this.tutorialActive) {
        this.hideTutorial();
      }
      
      // Save settings before disabling
      this.saveGridSettings();
      
      // Show debug notification
      this.showDebugNotification('Debug grid disabled.');
    }
    
    return this.debugEnabled;
  },
  
  /**
   * Cycle through measurement modes
   */
  cycleMeasurementMode() {
    const modes = ['distance', 'alignment', 'element'];
    const currentIndex = modes.indexOf(this.measurementMode);
    const nextIndex = (currentIndex + 1) % modes.length;
    this.measurementMode = modes[nextIndex];
    
    // Update the select dropdown in settings
    const modeSelect = this.settingsPanel.querySelector('#measurement-mode');
    modeSelect.value = this.measurementMode;
    
    // Reset measurement state
    this.measurementOrigin = null;
    this.measurementTarget = null;
    
    if (this.measurementElement) {
      this.measurementElement.style.display = 'none';
    }
    
    this.showDebugNotification(`Measurement mode: ${this.measurementMode}. Click to begin measuring.`);
  },
  
  /**
   * Toggle measurement tool
   */
  toggleMeasurementTool() {
    this.measurementEnabled = !this.measurementEnabled;
    
    // Toggle display of measurement options in settings panel
    const measurementOptions = this.settingsPanel.querySelector('.measurement-options');
    measurementOptions.style.display = this.measurementEnabled ? 'block' : 'none';
    
    if (this.measurementEnabled) {
      // Create measurement element if it doesn't exist
      if (!this.measurementElement) {
        this.measurementElement = document.createElement('div');
        this.measurementElement.className = 'debug-grid-measurement';
        document.body.appendChild(this.measurementElement);
        
        // Create measurement display for showing metrics
        this.measurementDisplay = document.createElement('div');
        this.measurementDisplay.className = 'debug-grid-measurement-display';
        document.body.appendChild(this.measurementDisplay);
      } else {
        this.measurementElement.style.display = 'block';
        this.measurementDisplay.style.display = 'block';
      }
      
      // Add mouse event listeners
      document.addEventListener('click', this.handleMeasurementClick);
      document.addEventListener('mousemove', this.handleMeasurementMove);
      
      // Add touch event listeners for mobile support
      document.addEventListener('touchstart', this.handleTouchStart, { passive: false });
      document.addEventListener('touchmove', this.handleTouchMove, { passive: false });
      document.addEventListener('touchend', this.handleTouchEnd, { passive: false });
      
      // Add touchscreen detection to body for CSS targeting
      if ('ontouchstart' in window) {
        document.body.classList.add('has-touch');
      }
      
      this.showDebugNotification(`Measurement tool enabled (${this.measurementMode} mode). ${this.getTouchInstructions()}`);
    } else {
      // Hide measurement element
      if (this.measurementElement) {
        this.measurementElement.style.display = 'none';
      }
      
      // Hide measurement display
      if (this.measurementDisplay) {
        this.measurementDisplay.style.display = 'none';
      }
      
      // Remove mouse event listeners
      document.removeEventListener('click', this.handleMeasurementClick);
      document.removeEventListener('mousemove', this.handleMeasurementMove);
      
      // Remove touch event listeners
      document.removeEventListener('touchstart', this.handleTouchStart);
      document.removeEventListener('touchmove', this.handleTouchMove);
      document.removeEventListener('touchend', this.handleTouchEnd);
      
      // Reset measurement points
      this.measurementOrigin = null;
      this.measurementTarget = null;
      
      this.showDebugNotification('Measurement tool disabled.');
    }
  },
  
  /**
   * Get appropriate instructions based on device type
   */
  getTouchInstructions() {
    return 'ontouchstart' in window 
      ? 'Tap to set origin point, tap again to measure.'
      : 'Click to set origin point.';
  },
  
  /**
   * Update measurement display based on options
   */
  updateMeasurementDisplay() {
    if (!this.measurementEnabled || !this.measurementOrigin || !this.measurementTarget) return;
    
    const options = {
      showPixels: this.settingsPanel.querySelector('input[name="show-pixels"]').checked,
      showCharacters: this.settingsPanel.querySelector('input[name="show-characters"]').checked,
      showLines: this.settingsPanel.querySelector('input[name="show-lines"]').checked
    };
    
    // Get font metrics
    const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
    const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height')) * charWidth;
    
    // Calculate distances
    const pixelDistanceX = Math.abs(this.measurementTarget.x - this.measurementOrigin.x);
    const pixelDistanceY = Math.abs(this.measurementTarget.y - this.measurementOrigin.y);
    const charDistance = Math.round(pixelDistanceX / charWidth * 10) / 10;
    const lineDistance = Math.round(pixelDistanceY / lineHeight * 10) / 10;
    
    // Build display text
    let displayText = '';
    
    if (options.showPixels) {
      displayText += `${pixelDistanceX}px × ${pixelDistanceY}px`;
    }
    
    if (options.showCharacters && options.showLines) {
      if (displayText) displayText += ' (';
      displayText += `${charDistance}ch × ${lineDistance} lines`;
      if (options.showPixels) displayText += ')';
    } else if (options.showCharacters) {
      if (displayText) displayText += ' (';
      displayText += `${charDistance}ch`;
      if (options.showPixels) displayText += ')';
    } else if (options.showLines) {
      if (displayText) displayText += ' (';
      displayText += `${lineDistance} lines`;
      if (options.showPixels) displayText += ')';
    }
    
    // Update the measurement display
    if (this.measurementElement) {
      this.measurementElement.setAttribute('data-measurement', displayText);
    }
    
    // Show in the separate measurement display element
    if (this.measurementDisplay) {
      this.measurementDisplay.textContent = displayText;
      
      // Position near but not over the measurement
      const left = Math.min(this.measurementOrigin.x, this.measurementTarget.x);
      const top = Math.min(this.measurementOrigin.y, this.measurementTarget.y) - 30; // Position above
      
      this.measurementDisplay.style.left = `${left}px`;
      this.measurementDisplay.style.top = `${top < 0 ? 0 : top}px`;
    }
  },
  
  /**
   * Handle measurement click
   */
  handleMeasurementClick(event) {
    // Prevent measuring when clicking on settings panel or notification
    if (event.target.closest('#debug-grid-settings') || 
        event.target.closest('#debug-notification')) {
      return;
    }
    
    switch (this.measurementMode) {
      case 'distance':
        this.handleDistanceMeasurementClick(event);
        break;
      case 'alignment':
        this.handleAlignmentMeasurementClick(event);
        break;
      case 'element':
        this.handleElementMeasurementClick(event);
        break;
    }
  },
  
  /**
   * Handle distance measurement click (point to point)
   */
  handleDistanceMeasurementClick(event) {
    if (!this.measurementOrigin) {
      this.measurementOrigin = {
        x: event.clientX,
        y: event.clientY
      };
      
      if (this.measurementDisplay) {
        this.measurementDisplay.style.display = 'block';
      }
      
      this.showDebugNotification('Origin point set. Click again to measure distance.');
    } else {
      this.measurementTarget = {
        x: event.clientX,
        y: event.clientY
      };
      
      // Update the display with final measurements
      this.updateMeasurementDisplay();
      
      // Reset for new measurement
      setTimeout(() => {
        this.measurementOrigin = null;
        this.measurementTarget = null;
        
        if (this.measurementElement) {
          this.measurementElement.style.display = 'none';
        }
        
        this.showDebugNotification('Measurement complete. Click to set a new origin point.');
      }, 3000);
    }
  },
  
  /**
   * Handle alignment measurement click (grid offset)
   */
  handleAlignmentMeasurementClick(event) {
    // Get font metrics
    const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
    const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height')) * charWidth;
    
    // Calculate grid alignment
    const x = event.clientX;
    const y = event.clientY;
    
    const offsetX = x % charWidth;
    const offsetY = y % lineHeight;
    
    const alignedX = Math.round(x / charWidth) * charWidth;
    const alignedY = Math.round(y / lineHeight) * lineHeight;
    
    // Create or update alignment marker
    if (!this.alignmentMarker) {
      this.alignmentMarker = document.createElement('div');
      this.alignmentMarker.className = 'debug-grid-alignment-marker';
      document.body.appendChild(this.alignmentMarker);
    }
    
    // Position the marker
    this.alignmentMarker.style.left = `${alignedX}px`;
    this.alignmentMarker.style.top = `${alignedY}px`;
    this.alignmentMarker.style.display = 'block';
    
    // Show alignment information
    const offsetXPercent = Math.round((offsetX / charWidth) * 100);
    const offsetYPercent = Math.round((offsetY / lineHeight) * 100);
    
    const message = `
      Grid alignment: 
      X offset: ${Math.round(offsetX)}px (${offsetXPercent}% of character width)
      Y offset: ${Math.round(offsetY)}px (${offsetYPercent}% of line height)
      Distance to nearest grid intersection: ${Math.round(Math.sqrt(offsetX * offsetX + offsetY * offsetY))}px
    `;
    
    this.showDebugNotification(message);
    
    // Hide alignment marker after delay
    setTimeout(() => {
      if (this.alignmentMarker) {
        this.alignmentMarker.style.display = 'none';
      }
    }, 3000);
  },
  
  /**
   * Handle element measurement click (element size & position)
   */
  handleElementMeasurementClick(event) {
    // Find the element under the cursor (but not debug elements)
    let element = document.elementFromPoint(event.clientX, event.clientY);
    
    // Skip measuring debug elements
    while (element && (
      element.id === 'debug-notification' || 
      element.id === 'debug-grid-settings' ||
      element.classList.contains('debug-grid-measurement') ||
      element.classList.contains('debug-grid-measurement-display') ||
      element.classList.contains('debug-grid-alignment-marker')
    )) {
      // Hide the element temporarily to get the element underneath
      const prevDisplay = element.style.display;
      element.style.display = 'none';
      const newElement = document.elementFromPoint(event.clientX, event.clientY);
      element.style.display = prevDisplay;
      
      if (newElement === element || !newElement) break;
      element = newElement;
    }
    
    if (!element) return;
    
    // Get element metrics
    const rect = element.getBoundingClientRect();
    
    // Get font metrics
    const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
    const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height')) * charWidth;
    
    // Calculate character-based measurements
    const widthInChars = Math.round(rect.width / charWidth * 10) / 10;
    const heightInLines = Math.round(rect.height / lineHeight * 10) / 10;
    
    // Calculate grid alignment
    const leftOffset = rect.left % charWidth;
    const topOffset = rect.top % lineHeight;
    const leftOffsetPercent = Math.round((leftOffset / charWidth) * 100);
    const topOffsetPercent = Math.round((topOffset / lineHeight) * 100);
    
    // Highlight the element
    const prevOutline = element.style.outline;
    element.style.outline = '2px solid rgba(255, 165, 0, 0.8)';
    
    // Show element information
    const message = `
      Element: ${element.tagName.toLowerCase()}${element.id ? '#' + element.id : ''}
      Size: ${Math.round(rect.width)}px × ${Math.round(rect.height)}px (${widthInChars}ch × ${heightInLines} lines)
      Position: ${Math.round(rect.left)}px, ${Math.round(rect.top)}px
      Grid alignment - X: ${leftOffsetPercent}%, Y: ${topOffsetPercent}%
    `;
    
    this.showDebugNotification(message);
    
    // Create element info display
    if (!this.elementInfoDisplay) {
      this.elementInfoDisplay = document.createElement('div');
      this.elementInfoDisplay.className = 'debug-grid-element-info';
      document.body.appendChild(this.elementInfoDisplay);
    }
    
    // Format detailed info
    this.elementInfoDisplay.innerHTML = `
      <div class="element-info-header">${element.tagName.toLowerCase()}${element.id ? '#' + element.id : ''}</div>
      <table class="element-info-table">
        <tr><td>Width</td><td>${Math.round(rect.width)}px (${widthInChars}ch)</td></tr>
        <tr><td>Height</td><td>${Math.round(rect.height)}px (${heightInLines} lines)</td></tr>
        <tr><td>Position</td><td>X: ${Math.round(rect.left)}px, Y: ${Math.round(rect.top)}px</td></tr>
        <tr><td>Grid Offset</td><td>X: ${Math.round(leftOffset)}px (${leftOffsetPercent}%), Y: ${Math.round(topOffset)}px (${topOffsetPercent}%)</td></tr>
        <tr><td>Classes</td><td>${element.className || 'none'}</td></tr>
      </table>
    `;
    
    // Position the info display next to the element
    this.elementInfoDisplay.style.left = `${rect.right + 10}px`;
    this.elementInfoDisplay.style.top = `${rect.top}px`;
    this.elementInfoDisplay.style.display = 'block';
    
    // Clean up after delay
    setTimeout(() => {
      element.style.outline = prevOutline;
      if (this.elementInfoDisplay) {
        this.elementInfoDisplay.style.display = 'none';
      }
    }, 5000);
  },
  
  /**
   * Handle mouse movement for measurement tool
   */
  handleMeasurementMove(event) {
    if (this.measurementMode === 'distance' && this.measurementOrigin) {
      const currentPos = {
        x: event.clientX,
        y: event.clientY
      };
      
      // Set target for calculations
      this.measurementTarget = currentPos;
      
      // Position and size the measurement rectangle
      const left = Math.min(this.measurementOrigin.x, currentPos.x);
      const top = Math.min(this.measurementOrigin.y, currentPos.y);
      const width = Math.abs(currentPos.x - this.measurementOrigin.x);
      const height = Math.abs(currentPos.y - this.measurementOrigin.y);
      
      this.measurementElement.style.left = `${left}px`;
      this.measurementElement.style.top = `${top}px`;
      this.measurementElement.style.width = `${width}px`;
      this.measurementElement.style.height = `${height}px`;
      this.measurementElement.style.display = 'block';
      
      // Update display
      this.updateMeasurementDisplay();
    }
  },
  
  /**
   * Show a temporary notification about debug grid state
   */
  showDebugNotification(message) {
    // Create or reuse notification element
    let notification = document.getElementById('debug-notification');
    if (!notification) {
      notification = document.createElement('div');
      notification.id = 'debug-notification';
      notification.style.position = 'fixed';
      notification.style.bottom = '20px';
      notification.style.right = '20px';
      notification.style.padding = '10px';
      notification.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
      notification.style.color = 'white';
      notification.style.borderRadius = '4px';
      notification.style.zIndex = '9999';
      notification.style.transition = 'opacity 0.3s';
      document.body.appendChild(notification);
    }
    
    // Set message and ensure it's visible
    notification.textContent = message;
    notification.style.opacity = '1';
    
    // Hide after a delay
    clearTimeout(this.notificationTimeout);
    this.notificationTimeout = setTimeout(() => {
      notification.style.opacity = '0';
    }, 3000);
  },
  
  /**
   * Highlight elements that are misaligned with the grid
   */
  highlightMisalignedElements() {
    if (!this.debugEnabled) return;
    
    // Cache CSS variables for performance
    const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
    const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height')) * charWidth;
    
    // Use requestAnimationFrame to avoid layout thrashing
    requestAnimationFrame(() => {
      document.querySelectorAll('*').forEach(el => {
        if (el.id === 'debug-notification' || 
            el.id === 'debug-grid-settings' || 
            el.classList.contains('debug-grid-measurement')) {
          return; // Skip debug elements
        }
        
        const rect = el.getBoundingClientRect();
        
        // Skip very small elements
        if (rect.width < 5 || rect.height < 5) return;
        
        const isOffGridX = rect.width % charWidth > 0.5;
        const isOffGridY = rect.height % lineHeight > 0.5;
        const isOffPosition = (rect.left % charWidth > 0.5) || (rect.top % lineHeight > 0.5);
        
        if (isOffGridX || isOffGridY || isOffPosition) {
          el.classList.add('off-grid');
          
          // Add data attributes with measurement info
          el.dataset.gridInfo = `${Math.round(rect.width / charWidth * 10) / 10}ch × ${Math.round(rect.height / lineHeight * 10) / 10} lines`;
        } else {
          el.classList.remove('off-grid');
          delete el.dataset.gridInfo;
        }
      });
    });
  },
  
  /**
   * Update grid sizing based on current font metrics and grid density
   */
  updateGridSizing() {
    if (!this.debugEnabled) return;
    
    const root = document.documentElement;
    const computedStyle = getComputedStyle(root);
    
    // Get font metrics
    const fontSizeInPx = parseFloat(computedStyle.fontSize);
    const lineHeightInRem = parseFloat(computedStyle.getPropertyValue('--line-height'));
    const lineHeightInPx = lineHeightInRem * fontSizeInPx;
    
    // Set grid cell size based on selected density
    let cellWidth = '1ch';
    switch (this.gridDensity) {
      case 'word':
        cellWidth = '5ch';
        break;
      case 'paragraph':
        cellWidth = '10ch';
        break;
      default: // character
        cellWidth = '1ch';
    }
    
    // Set CSS variables to adjust the grid
    root.style.setProperty('--debug-grid-cell-width', cellWidth);
    root.style.setProperty('--debug-grid-cell-height', `${lineHeightInPx}px`);
    
    // Update grid color if not already set
    if (!root.style.getPropertyValue('--debug-grid-color')) {
      root.style.setProperty('--debug-grid-color', 'rgba(0, 0, 255, 0.1)');
    }
    
    // Highlight misaligned elements
    this.highlightMisalignedElements();
    
    console.log('Debug grid updated:', {
      fontSizeInPx,
      lineHeightInRem,
      lineHeightInPx,
      gridDensity: this.gridDensity
    });
  },
  
  /**
   * Handle touch start event
   */
  handleTouchStart(event) {
    // Check for two-finger tap to cancel measurement
    if (event.touches.length >= 2) {
      // Cancel current measurement
      this.measurementOrigin = null;
      this.measurementTarget = null;
      
      // Update the visual state
      if (this.measurementElement) {
        this.measurementElement.style.display = 'none';
      }
      
      if (this.measurementDisplay) {
        this.measurementDisplay.style.display = 'none';
      }
      
      this.showDebugNotification('Measurement canceled. Tap to start a new measurement.');
      event.preventDefault();
      return;
    }
    
    // Prevent default to avoid scrolling and zooming while measuring
    event.preventDefault();
    
    // Prevent measuring when tapping on settings panel or notification
    if (event.target.closest('#debug-grid-settings') || 
        event.target.closest('#debug-notification')) {
      return;
    }
    
    // Get the touch coordinates
    const touch = event.touches[0];
    
    // Create a synthetic event with clientX and clientY
    const syntheticEvent = {
      clientX: touch.clientX,
      clientY: touch.clientY,
      target: touch.target
    };
    
    // Handle the touch as a click
    this.handleMeasurementClick(syntheticEvent);
  },
  
  /**
   * Handle touch move event
   */
  handleTouchMove(event) {
    // Prevent default to avoid scrolling while measuring
    event.preventDefault();
    
    // Only update if we have an origin point set
    if (!this.measurementOrigin) return;
    
    // Get the touch coordinates
    const touch = event.touches[0];
    
    // Create a synthetic event with clientX and clientY
    const syntheticEvent = {
      clientX: touch.clientX,
      clientY: touch.clientY
    };
    
    // Handle the touch as a mouse move
    this.handleMeasurementMove(syntheticEvent);
  },
  
  /**
   * Handle touch end event
   */
  handleTouchEnd(event) {
    // No action needed here as the touchstart already triggers the click handler
    // This is just for completeness
    event.preventDefault();
  },
  
  /**
   * Clean up when the component is destroyed
   */
  destroyed() {
    // Remove event listeners
    document.removeEventListener('keydown', this.handleKeyPress);
    window.removeEventListener('phx:resize', this.updateGridSizing);
    
    // Clean up measurement tool
    if (this.measurementEnabled) {
      document.removeEventListener('click', this.handleMeasurementClick);
      document.removeEventListener('mousemove', this.handleMeasurementMove);
    }
    
    // Remove the settings panel if it exists
    if (this.settingsPanel && this.settingsPanel.parentNode) {
      this.settingsPanel.parentNode.removeChild(this.settingsPanel);
    }
    
    // Remove the measurement element if it exists
    if (this.measurementElement && this.measurementElement.parentNode) {
      this.measurementElement.parentNode.removeChild(this.measurementElement);
    }
    
    // Remove the measurement display if it exists
    if (this.measurementDisplay && this.measurementDisplay.parentNode) {
      this.measurementDisplay.parentNode.removeChild(this.measurementDisplay);
    }
    
    // Remove alignment marker if it exists
    if (this.alignmentMarker && this.alignmentMarker.parentNode) {
      this.alignmentMarker.parentNode.removeChild(this.alignmentMarker);
    }
    
    // Remove element info display if it exists
    if (this.elementInfoDisplay && this.elementInfoDisplay.parentNode) {
      this.elementInfoDisplay.parentNode.removeChild(this.elementInfoDisplay);
    }
    
    // Remove global reference
    if (window.debugGrid === this) {
      window.debugGrid = null;
    }
    
    // Remove touch event listeners
    document.removeEventListener('touchstart', this.handleTouchStart);
    document.removeEventListener('touchmove', this.handleTouchMove);
    document.removeEventListener('touchend', this.handleTouchEnd);
  },
  
  /**
   * Save current grid settings to localStorage
   */
  saveGridSettings() {
    if (!this.debugEnabled) return;
    
    const settings = {
      gridDensity: this.gridDensity,
      measurementMode: this.measurementMode,
      gridColor: document.querySelector('#grid-color')?.value || '#0000ff',
      gridOpacity: document.querySelector('#grid-opacity')?.value || 0.1,
      measurementOptions: {
        showPixels: document.querySelector('input[name="show-pixels"]')?.checked ?? true,
        showCharacters: document.querySelector('input[name="show-characters"]')?.checked ?? true,
        showLines: document.querySelector('input[name="show-lines"]')?.checked ?? true
      }
    };
    
    try {
      localStorage.setItem('debugGridSettings', JSON.stringify(settings));
    } catch (e) {
      console.warn('Failed to save debug grid settings', e);
    }
  },
  
  /**
   * Restore grid settings from localStorage
   */
  restoreGridSettings() {
    try {
      const savedSettings = localStorage.getItem('debugGridSettings');
      if (!savedSettings) return;
      
      const settings = JSON.parse(savedSettings);
      
      // Restore grid density
      if (settings.gridDensity) {
        this.gridDensity = settings.gridDensity;
        const densitySelect = document.querySelector('#grid-density');
        if (densitySelect) {
          densitySelect.value = settings.gridDensity;
        }
      }
      
      // Restore grid color
      if (settings.gridColor) {
        const colorInput = document.querySelector('#grid-color');
        if (colorInput) {
          colorInput.value = settings.gridColor;
        }
      }
      
      // Restore grid opacity
      if (settings.gridOpacity) {
        const opacityInput = document.querySelector('#grid-opacity');
        if (opacityInput) {
          opacityInput.value = settings.gridOpacity;
          document.querySelector('#grid-opacity-value').textContent = settings.gridOpacity;
        }
      }
      
      // Restore measurement mode
      if (settings.measurementMode) {
        this.measurementMode = settings.measurementMode;
        const modeSelect = document.querySelector('#measurement-mode');
        if (modeSelect) {
          modeSelect.value = settings.measurementMode;
        }
      }
      
      // Restore measurement options
      if (settings.measurementOptions) {
        const { showPixels, showCharacters, showLines } = settings.measurementOptions;
        
        const pixelsCheckbox = document.querySelector('input[name="show-pixels"]');
        if (pixelsCheckbox) pixelsCheckbox.checked = showPixels;
        
        const charsCheckbox = document.querySelector('input[name="show-characters"]');
        if (charsCheckbox) charsCheckbox.checked = showCharacters;
        
        const linesCheckbox = document.querySelector('input[name="show-lines"]');
        if (linesCheckbox) linesCheckbox.checked = showLines;
      }
      
      // Update grid based on restored settings
      this.updateGridSizing();
    } catch (e) {
      console.warn('Failed to restore debug grid settings', e);
    }
  },
  
  /**
   * Show tutorial for the debug grid
   */
  showTutorial() {
    // Create tutorial element if it doesn't exist
    if (!this.tutorialElement) {
      this.tutorialElement = document.createElement('div');
      this.tutorialElement.className = 'debug-grid-tutorial';
      
      // Create highlight element for focusing on UI elements
      this.tutorialHighlight = document.createElement('div');
      this.tutorialHighlight.className = 'debug-grid-tutorial-highlight';
      document.body.appendChild(this.tutorialHighlight);
      
      this.tutorialElement.innerHTML = `
        <div class="debug-grid-tutorial-container ${('ontouchstart' in window) ? 'touch-friendly' : ''}">
          <div class="debug-grid-tutorial-header">
            <h3>Debug Grid Tutorial</h3>
            <button class="close-tutorial" aria-label="Close tutorial">×</button>
          </div>
          <div class="debug-grid-tutorial-content">
            <!-- Content will be dynamically inserted here -->
          </div>
          <div class="debug-grid-tutorial-progress">
            <!-- Progress dots will be inserted here -->
          </div>
          <div class="debug-grid-tutorial-nav">
            <button class="prev-button">Previous</button>
            <button class="next-button">Next</button>
          </div>
        </div>
      `;
      
      document.body.appendChild(this.tutorialElement);
      
      // Add event listeners
      const closeButton = this.tutorialElement.querySelector('.close-tutorial');
      closeButton.addEventListener('click', this.hideTutorial);
      
      const prevButton = this.tutorialElement.querySelector('.prev-button');
      prevButton.addEventListener('click', this.prevTutorialStep);
      
      const nextButton = this.tutorialElement.querySelector('.next-button');
      nextButton.addEventListener('click', this.nextTutorialStep);
    }
    
    // Show the tutorial
    this.tutorialActive = true;
    this.tutorialElement.style.display = 'flex';
    
    // Ensure tutorial is visible in the viewport
    window.scrollTo(0, 0);
    
    // Set explicit positioning to ensure visibility
    this.tutorialElement.style.position = 'fixed';
    this.tutorialElement.style.top = '0';
    this.tutorialElement.style.left = '0';
    this.tutorialElement.style.right = '0';
    this.tutorialElement.style.bottom = '0';
    this.tutorialElement.style.zIndex = '10000';
    this.tutorialElement.style.display = 'flex';
    this.tutorialElement.style.justifyContent = 'center';
    this.tutorialElement.style.alignItems = 'center';
    
    // Ensure visibility
    this.ensureVisible(this.tutorialElement);
    
    // Initialize tutorial to first step
    this.goToTutorialStep(0);
  },
  
  /**
   * Hide the tutorial
   */
  hideTutorial() {
    if (this.tutorialElement) {
      // Remove completely from DOM instead of just hiding
      if (this.tutorialElement.parentNode) {
        this.tutorialElement.parentNode.removeChild(this.tutorialElement);
      }
      this.tutorialElement = null;
    }
    
    if (this.tutorialHighlight) {
      if (this.tutorialHighlight.parentNode) {
        this.tutorialHighlight.parentNode.removeChild(this.tutorialHighlight);
      }
      this.tutorialHighlight = null;
    }
    
    // Ensure any potential barriers to clicks are removed
    document.querySelectorAll('.debug-grid-tutorial').forEach(el => {
      if (el.parentNode) {
        el.parentNode.removeChild(el);
      }
    });
    
    // Reset state
    this.tutorialActive = false;
    
    // Ensure body can receive clicks
    document.body.style.pointerEvents = 'auto';
    
    console.log('Tutorial cleaned up, pointer events should work now');
  },
  
  /**
   * Go to the next tutorial step
   */
  nextTutorialStep() {
    this.goToTutorialStep(this.tutorialStep + 1);
  },
  
  /**
   * Go to the previous tutorial step
   */
  prevTutorialStep() {
    this.goToTutorialStep(this.tutorialStep - 1);
  },
  
  /**
   * Go to a specific tutorial step
   */
  goToTutorialStep(step) {
    // Define the tutorial steps
    const tutorialSteps = [
      {
        title: "Welcome to Debug Grid!",
        content: `
          <p>This tutorial will guide you through using the Debug Grid tool for precise layout and measurement.</p>
          
          <p>The Debug Grid helps you:</p>
          <ul>
            <li>Visualize character and line spacing</li>
            <li>Measure distances and element sizes</li>
            <li>Ensure proper alignment of UI elements</li>
            <li>Debug layout issues</li>
          </ul>
          
          <p class="tutorial-tip">Click <strong>Next</strong> to learn about the basic features.</p>
        `
      },
      {
        title: "Grid Density & Appearance",
        content: `
          <p>You can customize how the grid appears using these controls:</p>
          
          <ul>
            <li><span class="highlight">Grid Density</span>: Change the size of grid cells</li>
            <li><span class="highlight">Grid Color</span>: Change the color of grid lines</li>
            <li><span class="highlight">Grid Opacity</span>: Make the grid more or less visible</li>
          </ul>
          
          <p>Try different settings to find what works best for your project.</p>
          
          <p class="tutorial-tip">The Character mode (1ch) is best for precise alignment, while Word and Paragraph modes provide a broader view.</p>
        `,
        highlightSelector: "#grid-density, #grid-color, #grid-opacity"
      },
      {
        title: "Measurement Tools",
        content: `
          <p>The Debug Grid includes powerful measurement tools:</p>
          
          <ul>
            <li><span class="highlight">Toggle Measurement Tool</span>: Start/stop measuring</li>
            <li><span class="highlight">Measurement Mode</span>: Choose from Distance, Alignment, or Element modes</li>
          </ul>
          
          <p>Each mode provides different information:</p>
          <ul>
            <li><strong>Distance</strong>: Measure from point to point</li>
            <li><strong>Alignment</strong>: Check if elements align with the grid</li>
            <li><strong>Element</strong>: Measure size and position of UI elements</li>
          </ul>
          
          <p class="tutorial-tip">Click to set the starting point, then click again or drag to measure the distance.</p>
        `,
        highlightSelector: "#toggle-measurements, #measurement-mode"
      },
      {
        title: "Keyboard Shortcuts",
        content: `
          <p>Speed up your workflow with these keyboard shortcuts:</p>
          
          <ul>
            <li><kbd>Alt</kbd> + <kbd>G</kbd>: Toggle the Debug Grid on/off</li>
            <li><kbd>Alt</kbd> + <kbd>M</kbd>: Toggle Measurement Tool</li>
            <li><kbd>Alt</kbd> + <kbd>S</kbd>: Show/Hide Settings Panel</li>
            <li><kbd>Alt</kbd> + <kbd>1-3</kbd>: Change Grid Density</li>
            <li><kbd>Esc</kbd>: Cancel current measurement</li>
          </ul>
          
          <p>For the full list of shortcuts, click the <span class="highlight">Show Keyboard Shortcuts</span> button in the settings panel.</p>
          
          <p class="tutorial-tip">Keyboard shortcuts work even when the settings panel is closed.</p>
        `,
        highlightSelector: "#toggle-shortcuts"
      },
      {
        title: "Touch Device Support",
        content: `
          <p>The Debug Grid works great on touch devices too:</p>
          
          <ul>
            <li><strong>Tap once</strong> to set measurement origin</li>
            <li><strong>Tap again</strong> to complete measurement</li>
            <li><strong>Drag</strong> to see real-time measurements</li>
            <li><strong>Two-finger tap</strong> to cancel measurement</li>
          </ul>
          
          <p>The interface automatically adapts to provide larger touch targets on mobile devices.</p>
          
          <p class="tutorial-tip">All settings are saved between sessions, so your preferences will be remembered.</p>
        `,
        highlightSelector: '.touch-instructions'
      },
      {
        title: "You're Ready to Go!",
        content: `
          <p>Congratulations! You now know how to use the Debug Grid.</p>
          
          <p>Remember:</p>
          <ul>
            <li>Press <kbd>Alt</kbd> + <kbd>G</kbd> to toggle the grid on/off</li>
            <li>Click <span class="highlight">Show Tutorial</span> to see this tutorial again</li>
            <li>Explore different measurement modes for different tasks</li>
          </ul>
          
          <p>Happy debugging!</p>
        `,
        highlightSelector: "#show-tutorial"
      }
    ];
    
    // Validate step range
    if (step < 0) step = 0;
    if (step >= tutorialSteps.length) {
      this.hideTutorial();
      return;
    }
    
    // Update current step
    this.tutorialStep = step;
    const currentStep = tutorialSteps[step];
    
    // Update content
    const contentElement = this.tutorialElement.querySelector('.debug-grid-tutorial-content');
    contentElement.innerHTML = `
      <h4>${currentStep.title}</h4>
      ${currentStep.content}
    `;
    
    // Update progress dots
    const progressElement = this.tutorialElement.querySelector('.debug-grid-tutorial-progress');
    progressElement.innerHTML = '';
    for (let i = 0; i < tutorialSteps.length; i++) {
      const dot = document.createElement('div');
      dot.className = `progress-dot ${i === step ? 'active' : ''}`;
      dot.addEventListener('click', () => this.goToTutorialStep(i));
      progressElement.appendChild(dot);
    }
    
    // Update navigation buttons
    const prevButton = this.tutorialElement.querySelector('.prev-button');
    const nextButton = this.tutorialElement.querySelector('.next-button');
    
    prevButton.disabled = step === 0;
    
    if (step === tutorialSteps.length - 1) {
      nextButton.textContent = 'Finish';
    } else {
      nextButton.textContent = 'Next';
    }
    
    // Highlight UI element if specified
    if (currentStep.highlightSelector) {
      const elements = document.querySelectorAll(currentStep.highlightSelector);
      if (elements.length > 0) {
        // Use the first element if multiple are selected
        const element = elements[0];
        const rect = element.getBoundingClientRect();
        
        this.tutorialHighlight.style.display = 'block';
        this.tutorialHighlight.style.width = `${rect.width + 10}px`;
        this.tutorialHighlight.style.height = `${rect.height + 10}px`;
        this.tutorialHighlight.style.left = `${rect.left - 5}px`;
        this.tutorialHighlight.style.top = `${rect.top - 5}px`;
      } else {
        this.tutorialHighlight.style.display = 'none';
      }
    } else {
      this.tutorialHighlight.style.display = 'none';
    }
  },
  
  /**
   * Ensure an element is visible in the viewport
   * @param {HTMLElement} element - The element to ensure is visible
   */
  ensureVisible(element) {
    // Force browser to recalculate layout
    void element.offsetWidth;
    
    const rect = element.getBoundingClientRect();
    const isInViewport = (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
    
    if (!isInViewport) {
      // If not in viewport, position at the center of current viewport
      const viewportHeight = window.innerHeight || document.documentElement.clientHeight;
      const viewportWidth = window.innerWidth || document.documentElement.clientWidth;
      
      // Force the position to be in the middle of the current viewport
      element.style.position = 'fixed';
      element.style.top = '0';
      element.style.left = '0';
      element.style.width = '100%';
      element.style.height = '100%';
      
      // Log the viewport dimensions for debugging
      console.log('Viewport dimensions:', {
        width: viewportWidth,
        height: viewportHeight,
        scrollY: window.scrollY,
        documentHeight: document.documentElement.scrollHeight
      });
    }
  },
  
  /**
   * Clean up any existing tutorials from previous page load
   */
  cleanupExistingTutorials() {
    // Remove any existing tutorial elements from the DOM
    const existingTutorials = document.querySelectorAll('.debug-grid-tutorial');
    existingTutorials.forEach(el => {
      if (el.parentNode) {
        el.parentNode.removeChild(el);
      }
    });
  }
};

// Make methods accessible to other modules
// while maintaining compatibility with LiveView hooks
if (typeof window !== 'undefined') {
  window.DebugGrid = DebugGrid;
  
  // Emergency fix for debug grid issues
  window.addEventListener('DOMContentLoaded', function() {
    // Wait a moment for the page to be fully loaded
    setTimeout(function() {
      debugGridEmergencyFix();
    }, 1000);
  });
}

/**
 * Emergency fix for debug grid issues
 * This creates a simple button that toggles the grid without interfering with existing UI
 */
function debugGridEmergencyFix() {
  // First clean up any existing debug elements that might be blocking clicks
  document.querySelectorAll('.debug-grid-tutorial, #debug-grid-settings, #debug-grid-overlay').forEach(el => {
    if (el && el.parentNode) {
      el.parentNode.removeChild(el);
    }
  });
  
  // Reset any localStorage settings that might be causing issues
  localStorage.removeItem('debugGridTutorialSeen');
  
  // Create a simple toggle button
  const toggleButton = document.createElement('button');
  toggleButton.textContent = 'Toggle Grid';
  toggleButton.style.position = 'fixed';
  toggleButton.style.bottom = '20px';
  toggleButton.style.right = '20px';
  toggleButton.style.zIndex = '10000';
  toggleButton.style.padding = '10px 15px';
  toggleButton.style.backgroundColor = '#3b82f6';
  toggleButton.style.color = 'white';
  toggleButton.style.border = 'none';
  toggleButton.style.borderRadius = '4px';
  toggleButton.style.cursor = 'pointer';
  toggleButton.style.fontFamily = 'system-ui, sans-serif';
  toggleButton.style.fontSize = '14px';
  toggleButton.style.fontWeight = 'bold';
  toggleButton.style.boxShadow = '0 2px 5px rgba(0,0,0,0.2)';
  
  // Add hover effect
  toggleButton.addEventListener('mouseover', function() {
    this.style.backgroundColor = '#2563eb';
  });
  
  toggleButton.addEventListener('mouseout', function() {
    this.style.backgroundColor = '#3b82f6';
  });
  
  // Add click handler
  toggleButton.addEventListener('click', function() {
    // Toggle grid class on body
    document.body.classList.toggle('debug-grid');
    
    // Simple notification
    alert(document.body.classList.contains('debug-grid') ? 
          "Debug grid enabled - click again to disable" : 
          "Debug grid disabled");
  });
  
  // Add to the document
  document.body.appendChild(toggleButton);
  
  console.log('Emergency debug grid button has been added to the bottom right corner');
}

export default DebugGrid; 