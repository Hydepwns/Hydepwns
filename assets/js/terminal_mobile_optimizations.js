/**
 * Terminal Mobile Optimizations
 * ----------------------------
 * JavaScript performance enhancements for terminal on mobile devices
 */

const TerminalMobileOptimizations = {
  // Configuration
  config: {
    maxVisibleLines: 200,           // Maximum number of visible lines before virtualization
    mobileBreakpoint: 768,          // Mobile breakpoint in pixels
    smallScreenBreakpoint: 480,     // Small screen breakpoint in pixels
    enableVirtualization: true,     // Enable DOM virtualization for performance
    enableTouchControls: true,      // Enable touch-specific controls
    enablePerformanceMode: true,    // Enable performance optimizations
    debounceTime: 150,              // Debounce time for scroll/resize events in ms
    idleTimeout: 5000,              // Time before idle mode is activated in ms
    observerThreshold: 0.1,         // Intersection observer threshold
  },

  // State
  state: {
    isMobile: false,
    isSmallScreen: false,
    isTouchDevice: false,
    isLowPerformance: false,
    isBatteryLow: false,
    isFullscreen: false,
    isIdle: false,
    lastInteraction: Date.now(),
    visibleLines: [],
    batteryLevel: 1.0,
    batteryCharging: true,
    resizeTimeout: null,
    scrollTimeout: null,
    idleTimeout: null,
    terminal: null,
    terminalScreen: null,
    mobileControls: null,
    virtualControls: null,
    batteryStatus: null,
  },

  // Methods
  init: function() {
    // Check if we're in a browser environment
    if (typeof window === 'undefined') return;

    // Initialize state
    this.detectEnvironment();
    this.setupTerminalElements();
    
    if (!this.state.terminal) return;

    // Add device-specific classes
    this.addDeviceClasses();
    
    // Create mobile-specific UI elements if needed
    if (this.state.isMobile && this.config.enableTouchControls) {
      this.createMobileControls();
    }
    
    // Setup virtualization if enabled
    if (this.config.enableVirtualization && this.state.terminalScreen) {
      this.setupVirtualization();
    }
    
    // Setup event listeners
    this.setupEventListeners();
    
    // Monitor battery if available
    this.monitorBattery();
    
    // Apply initial optimizations
    this.applyOptimizations();
    
    console.log('Terminal Mobile Optimizations initialized');
  },
  
  detectEnvironment: function() {
    this.state.isMobile = window.innerWidth <= this.config.mobileBreakpoint;
    this.state.isSmallScreen = window.innerWidth <= this.config.smallScreenBreakpoint;
    
    // Detect touch device
    this.state.isTouchDevice = ('ontouchstart' in window) || 
                              (navigator.maxTouchPoints > 0) || 
                              (navigator.msMaxTouchPoints > 0);
    
    // Attempt to detect low-performance devices
    this.state.isLowPerformance = this.detectLowPerformance();
    
    console.log('Environment detected:', {
      isMobile: this.state.isMobile,
      isSmallScreen: this.state.isSmallScreen,
      isTouchDevice: this.state.isTouchDevice,
      isLowPerformance: this.state.isLowPerformance
    });
  },
  
  detectLowPerformance: function() {
    // Simple heuristics to detect low-performance devices
    const isLowMemory = navigator.deviceMemory && navigator.deviceMemory < 4;
    const isSlowCPU = navigator.hardwareConcurrency && navigator.hardwareConcurrency < 4;
    const isLowEnd = isLowMemory || isSlowCPU;
    
    return isLowEnd || this.state.isSmallScreen;
  },
  
  setupTerminalElements: function() {
    // Find the terminal elements
    this.state.terminal = document.querySelector('.terminal-container');
    
    if (!this.state.terminal) return;
    
    this.state.terminalScreen = this.state.terminal.querySelector('.terminal-screen');
    this.state.terminalInput = this.state.terminal.querySelector('.terminal-input');
  },
  
  addDeviceClasses: function() {
    // Add classes to body for targeting specific device types
    if (this.state.isMobile) {
      document.body.classList.add('mobile-device');
    }
    
    if (this.state.isSmallScreen) {
      document.body.classList.add('small-screen');
    }
    
    if (this.state.isTouchDevice) {
      document.body.classList.add('touch-device');
    }
    
    if (this.state.isLowPerformance) {
      document.body.classList.add('low-performance');
    }
  },
  
  createMobileControls: function() {
    // Check if controls already exist
    if (document.querySelector('.terminal-mobile-controls')) return;
    
    // Create mobile controls container
    const mobileControls = document.createElement('div');
    mobileControls.className = 'terminal-mobile-controls';
    
    // Create common terminal control buttons
    const commonControls = [
      { text: 'Tab', action: this.sendTabKey.bind(this) },
      { text: 'Ctrl+C', action: this.sendCtrlC.bind(this) },
      { text: 'Ctrl+D', action: this.sendCtrlD.bind(this) },
      { text: 'Clear', action: this.clearTerminal.bind(this) },
      { text: '⤢', action: this.toggleFullscreen.bind(this) }
    ];
    
    // Add buttons to the controls container
    commonControls.forEach(control => {
      const button = document.createElement('button');
      button.className = 'terminal-mobile-button';
      button.textContent = control.text;
      button.addEventListener('click', control.action);
      button.setAttribute('aria-label', `Terminal ${control.text} command`);
      mobileControls.appendChild(button);
    });
    
    // Add the controls to the terminal
    this.state.terminal.appendChild(mobileControls);
    this.state.mobileControls = mobileControls;
  },
  
  setupVirtualization: function() {
    // Setup intersection observer for virtualization
    if ('IntersectionObserver' in window) {
      const options = {
        root: this.state.terminalScreen,
        threshold: this.config.observerThreshold
      };
      
      const observer = new IntersectionObserver(this.handleIntersection.bind(this), options);
      
      // Observe all terminal lines
      const terminalLines = this.state.terminalScreen.querySelectorAll('.terminal-line');
      terminalLines.forEach(line => observer.observe(line));
      
      // Store reference to observer
      this.state.observer = observer;
    }
  },
  
  handleIntersection: function(entries) {
    entries.forEach(entry => {
      // If the entry is not intersecting, hide its content to save resources
      if (!entry.isIntersecting && entry.target.classList.contains('terminal-line')) {
        entry.target.dataset.content = entry.target.textContent;
        entry.target.textContent = '';
        entry.target.style.height = `${entry.target.offsetHeight}px`;
      } else if (entry.isIntersecting && entry.target.dataset.content) {
        // Restore content when back in view
        entry.target.textContent = entry.target.dataset.content;
        entry.target.style.height = '';
        delete entry.target.dataset.content;
      }
    });
  },
  
  setupEventListeners: function() {
    // Window resize
    window.addEventListener('resize', this.debounce(this.handleResize.bind(this), this.config.debounceTime));
    
    // Terminal scroll
    if (this.state.terminalScreen) {
      this.state.terminalScreen.addEventListener('scroll', this.debounce(this.handleScroll.bind(this), this.config.debounceTime));
    }
    
    // User interaction events to reset idle timer
    ['click', 'touchstart', 'mousemove', 'keydown'].forEach(eventType => {
      document.addEventListener(eventType, this.resetIdleTimer.bind(this));
    });
    
    // Set initial idle timer
    this.resetIdleTimer();
    
    // Listen for device orientation changes
    window.addEventListener('orientationchange', this.handleOrientationChange.bind(this));
    
    // Focus management for input
    if (this.state.terminalInput) {
      this.state.terminalInput.addEventListener('focus', this.handleInputFocus.bind(this));
      this.state.terminalInput.addEventListener('blur', this.handleInputBlur.bind(this));
    }
  },
  
  monitorBattery: function() {
    // Check if Battery API is available
    if ('getBattery' in navigator) {
      navigator.getBattery().then(this.handleBatteryStatus.bind(this));
    }
  },
  
  handleBatteryStatus: function(battery) {
    // Store battery object
    this.state.batteryStatus = battery;
    
    // Update battery state
    this.updateBatteryState(battery);
    
    // Listen for battery changes
    battery.addEventListener('levelchange', () => this.updateBatteryState(battery));
    battery.addEventListener('chargingchange', () => this.updateBatteryState(battery));
  },
  
  updateBatteryState: function(battery) {
    this.state.batteryLevel = battery.level;
    this.state.batteryCharging = battery.charging;
    this.state.isBatteryLow = !battery.charging && battery.level <= 0.2;
    
    // Apply battery saving mode if battery is low
    if (this.state.isBatteryLow) {
      document.body.classList.add('battery-saving');
    } else {
      document.body.classList.remove('battery-saving');
    }
  },
  
  applyOptimizations: function() {
    if (!this.state.terminal) return;
    
    // Apply performance optimizations based on device capabilities
    if (this.state.isMobile || this.state.isLowPerformance) {
      this.limitTerminalOutput();
    }
    
    // Apply touch-specific optimizations
    if (this.state.isTouchDevice) {
      this.optimizeForTouch();
    }
  },
  
  limitTerminalOutput: function() {
    if (!this.state.terminalScreen) return;
    
    // Get all terminal lines
    const terminalLines = this.state.terminalScreen.querySelectorAll('.terminal-line');
    
    // If we have more than the max, hide the oldest ones
    if (terminalLines.length > this.config.maxVisibleLines) {
      for (let i = 0; i < terminalLines.length - this.config.maxVisibleLines; i++) {
        terminalLines[i].style.display = 'none';
      }
    }
  },
  
  optimizeForTouch: function() {
    if (!this.state.terminalInput) return;
    
    // Increase height of input for better touch targeting
    this.state.terminalInput.style.height = '38px';
    
    // Set font-size to prevent iOS zoom
    this.state.terminalInput.style.fontSize = '16px';
  },
  
  // Event handlers
  handleResize: function() {
    // Update device type detection
    this.detectEnvironment();
    
    // Update device classes
    this.addDeviceClasses();
    
    // Re-apply optimizations
    this.applyOptimizations();
  },
  
  handleScroll: function() {
    // Reset idle timer on scroll
    this.resetIdleTimer();
  },
  
  handleOrientationChange: function() {
    // Apply optimizations after orientation change
    setTimeout(() => {
      this.detectEnvironment();
      this.applyOptimizations();
    }, 300);
  },
  
  handleInputFocus: function() {
    if (this.state.isMobile) {
      // Scroll to input when focused
      setTimeout(() => {
        this.state.terminalInput.scrollIntoView({ behavior: 'smooth' });
      }, 300);
    }
  },
  
  handleInputBlur: function() {
    // Nothing special needed here yet
  },
  
  // Utility methods
  resetIdleTimer: function() {
    // Update last interaction time
    this.state.lastInteraction = Date.now();
    this.state.isIdle = false;
    
    // Remove idle class if it exists
    document.body.classList.remove('terminal-idle');
    
    // Clear existing timeout
    if (this.state.idleTimeout) {
      clearTimeout(this.state.idleTimeout);
    }
    
    // Set new timeout
    this.state.idleTimeout = setTimeout(() => {
      this.state.isIdle = true;
      document.body.classList.add('terminal-idle');
    }, this.config.idleTimeout);
  },
  
  debounce: function(func, wait) {
    return (...args) => {
      clearTimeout(this.state.debounceTimeout);
      this.state.debounceTimeout = setTimeout(() => func.apply(this, args), wait);
    };
  },
  
  // Touch control actions
  sendTabKey: function() {
    if (!this.state.terminalInput) return;
    
    // Focus the input
    this.state.terminalInput.focus();
    
    // Create and dispatch a tab key event
    const tabEvent = new KeyboardEvent('keydown', {
      key: 'Tab',
      code: 'Tab',
      keyCode: 9,
      which: 9,
      bubbles: true,
      cancelable: true
    });
    
    this.state.terminalInput.dispatchEvent(tabEvent);
  },
  
  sendCtrlC: function() {
    if (!this.state.terminalInput) return;
    
    // Focus the input
    this.state.terminalInput.focus();
    
    // Create and dispatch Ctrl+C event
    const ctrlCEvent = new KeyboardEvent('keydown', {
      key: 'c',
      code: 'KeyC',
      keyCode: 67,
      which: 67,
      ctrlKey: true,
      bubbles: true,
      cancelable: true
    });
    
    this.state.terminalInput.dispatchEvent(ctrlCEvent);
  },
  
  sendCtrlD: function() {
    if (!this.state.terminalInput) return;
    
    // Focus the input
    this.state.terminalInput.focus();
    
    // Create and dispatch Ctrl+D event
    const ctrlDEvent = new KeyboardEvent('keydown', {
      key: 'd',
      code: 'KeyD',
      keyCode: 68,
      which: 68,
      ctrlKey: true,
      bubbles: true,
      cancelable: true
    });
    
    this.state.terminalInput.dispatchEvent(ctrlDEvent);
  },
  
  clearTerminal: function() {
    if (!this.state.terminalScreen) return;
    
    // Create and dispatch a custom clear event
    const clearEvent = new CustomEvent('terminal:clear');
    this.state.terminal.dispatchEvent(clearEvent);
    
    // Fallback: clear the terminal screen manually
    const lines = this.state.terminalScreen.querySelectorAll('.terminal-line');
    if (lines.length > 0) {
      lines.forEach(line => line.remove());
    }
  },
  
  toggleFullscreen: function() {
    if (!this.state.terminal) return;
    
    // Toggle fullscreen class
    this.state.terminal.classList.toggle('terminal-fullscreen');
    this.state.isFullscreen = this.state.terminal.classList.contains('terminal-fullscreen');
    
    // Update fullscreen button text
    const fullscreenButton = this.state.mobileControls?.querySelector('button:last-child');
    if (fullscreenButton) {
      fullscreenButton.textContent = this.state.isFullscreen ? '⤡' : '⤢';
    }
  }
};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  TerminalMobileOptimizations.init();
});

// Export for module usage
export default TerminalMobileOptimizations; 