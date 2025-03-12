/**
 * Mobile Performance Optimizations
 * 
 * This module contains optimizations specifically targeted at mobile devices,
 * including lazy loading, deferred execution, and touch interaction improvements.
 */

import { isBatteryLow, getBatteryInfo } from './battery_optimizations';

class MobileOptimizations {
  constructor() {
    this.initialized = false;
    this.isLowEndDevice = false;
    this.deviceInfo = null;
    this.batteryStatus = null;
  }

  // Initialize mobile optimizations
  async init() {
    if (this.initialized) return;
    
    // Get device information
    this.deviceInfo = this.getDeviceInfo();
    console.log('Device info:', this.deviceInfo);
    
    // Apply device specific classes
    this.applyDeviceSpecificStyles();
    
    // Check for battery status
    try {
      this.batteryStatus = await getBatteryInfo();
      this.handleBatteryStatus(this.batteryStatus);
      
      // Add battery status event listeners
      if (this.batteryStatus && typeof this.batteryStatus.addEventListener === 'function') {
        this.batteryStatus.addEventListener('levelchange', () => this.handleBatteryStatus(this.batteryStatus));
        this.batteryStatus.addEventListener('chargingchange', () => this.handleBatteryStatus(this.batteryStatus));
      }
    } catch (error) {
      console.error('Battery API not supported or error:', error);
    }
    
    // Setup device specific rendering
    this.setupDeviceSpecificRendering();
    
    // Setup intersection observer for lazy loading
    this.setupLazyLoading();
    
    this.initialized = true;
    console.log('Mobile optimizations initialized');
  }
  
  // Get detailed information about the device
  getDeviceInfo() {
    const ua = navigator.userAgent;
    const platform = navigator.platform;
    const screenWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    const screenHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
    const pixelRatio = window.devicePixelRatio || 1;
    const touchSupport = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    const lowRAM = navigator.deviceMemory && navigator.deviceMemory <= 2; // 2GB RAM as threshold
    const lowCPU = navigator.hardwareConcurrency && navigator.hardwareConcurrency <= 4; // 4 cores as threshold
    
    // Determine device type
    let deviceType = 'desktop';
    if (/Mobi|Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ua)) {
      deviceType = /iPad|Tablet|Nexus 9|Nexus 10/i.test(ua) || (screenWidth > 768 && touchSupport) ? 'tablet' : 'mobile';
    }
    
    // Determine OS
    let os = 'other';
    if (/Windows/.test(ua)) os = 'windows';
    else if (/Android/.test(ua)) os = 'android';
    else if (/iPhone|iPad|iPod/.test(ua) || /Mac/.test(platform) && touchSupport) os = 'ios';
    else if (/Linux/.test(platform)) os = 'linux';
    else if (/Mac/.test(platform)) os = 'macos';
    
    // Determine browser
    let browser = 'other';
    if (/Firefox/.test(ua)) browser = 'firefox';
    else if (/SamsungBrowser/.test(ua)) browser = 'samsung';
    else if (/MSIE|Trident/.test(ua)) browser = 'ie';
    else if (/Edge/.test(ua)) browser = 'edge';
    else if (/Chrome/.test(ua)) browser = 'chrome';
    else if (/Safari/.test(ua)) browser = 'safari';
    
    // Determine device generation
    let generation = 'high-end';
    // Check for low-end device signs
    if (lowRAM || lowCPU || pixelRatio < 2 || (performance.memory && performance.memory.jsHeapSizeLimit < 2097152000)) {
      generation = 'low-end';
    } 
    // Mid-range devices
    else if (pixelRatio < 3 || (performance.memory && performance.memory.jsHeapSizeLimit < 4194304000)) {
      generation = 'mid-range';
    }
    
    // For iOS, determine generation by model identifier if possible
    if (os === 'ios') {
      // Rough estimation of iOS generation based on version in UA
      const match = ua.match(/OS (\d+)_/);
      const iosVersion = match ? parseInt(match[1], 10) : 0;
      
      if (iosVersion <= 10) {
        generation = 'low-end';
      } else if (iosVersion <= 14) {
        generation = 'mid-range';
      }
    }
    
    // For Android, use similar heuristics
    if (os === 'android') {
      const match = ua.match(/Android (\d+)\.(\d+)/);
      const androidVersion = match ? parseFloat(match[1] + '.' + match[2]) : 0;
      
      if (androidVersion <= 7) {
        generation = 'low-end';
      } else if (androidVersion <= 9) {
        generation = 'mid-range';
      }
    }
    
    // Additional checks for older devices
    if (screen.width * screen.height <= 480 * 800) {
      generation = 'low-end';
    }
    
    // Determine capabilities
    const capabilities = {
      touch: touchSupport,
      hover: !touchSupport || (os === 'windows' || os === 'macos' || os === 'linux'),
      screenSize: {
        width: screenWidth,
        height: screenHeight,
        pixelRatio: pixelRatio
      },
      memory: navigator.deviceMemory || null,
      cores: navigator.hardwareConcurrency || null,
      connection: navigator.connection ? {
        type: navigator.connection.effectiveType,
        saveData: navigator.connection.saveData
      } : null
    };
    
    // Set isLowEndDevice property
    this.isLowEndDevice = generation === 'low-end';
    
    return {
      type: deviceType,
      os,
      browser,
      generation,
      capabilities
    };
  }
  
  // Apply device-specific CSS classes to the document
  applyDeviceSpecificStyles() {
    if (!this.deviceInfo) return;
    
    const { type, os, generation, capabilities } = this.deviceInfo;
    const html = document.documentElement;
    
    // Add device type class
    html.classList.add(`device-${type}`);
    
    // Add OS class
    html.classList.add(`os-${os}`);
    
    // Add generation class
    html.classList.add(`device-generation-${generation}`);
    
    // Add capability classes
    if (!capabilities.hover) {
      html.classList.add('no-hover');
    }
    
    if (capabilities.touch) {
      html.classList.add('optimize-for-touch');
    }
    
    // Add high resolution screen class if applicable
    if (capabilities.screenSize.pixelRatio >= 2) {
      html.classList.add('high-res-text');
    }
    
    // Add small screen optimizations if needed
    if (capabilities.screenSize.width < 768) {
      html.classList.add('simplify-rendering');
      html.classList.add('mobile-font-optimization');
    }
    
    // Add animation optimizations based on device generation
    if (generation === 'low-end') {
      html.classList.add('minimal-animations');
      html.classList.add('simple-shadows');
      html.classList.add('use-system-fonts');
    } else if (generation === 'mid-range') {
      html.classList.add('optimize-animations');
      html.classList.add('optimize-shadows');
    }
    
    // Add specific OS optimizations
    if (os === 'android') {
      html.classList.add('simplify-transitions');
    }

    // Apply terminal-specific classes if terminal exists
    const terminalContainer = document.querySelector('.terminal-container');
    if (terminalContainer) {
      terminalContainer.classList.add(`terminal-os-${os}`);
      terminalContainer.classList.add(`terminal-generation-${generation}`);
      
      if (capabilities.touch) {
        terminalContainer.classList.add('terminal-touch-optimized');
      }
    }
    
    console.log('Applied device-specific styles', {
      type,
      os,
      generation,
      classes: html.className
    });
  }

  // Handle battery status changes
  handleBatteryStatus(battery) {
    console.log('Battery status:', battery);
    
    // Remove existing battery notices
    this.removeBatteryNotices();
    
    // Apply performance optimizations when battery is low
    if (battery && !battery.charging) {
      // Low battery threshold (15%)
      if (battery.level <= 0.15) {
        this.applyLowBatteryOptimizations();
        
        // Show notice for very low battery
        if (battery.level <= 0.05) {
          this.showBatteryNotice('critical', 'Battery critically low. Heavy optimizations applied.');
        } else {
          this.showBatteryNotice('low', 'Battery low. Performance optimizations applied.');
        }
      }
    }
  }
  
  // Remove all battery notices
  removeBatteryNotices() {
    const notices = document.querySelectorAll('.battery-notice');
    notices.forEach(notice => {
      notice.classList.add('battery-notice-hiding');
      setTimeout(() => {
        if (notice.parentNode) {
          notice.parentNode.removeChild(notice);
        }
      }, 300);
    });
  }
  
  // Show battery notice
  showBatteryNotice(level, message) {
    const notice = document.createElement('div');
    notice.className = `battery-notice battery-notice-${level}`;
    
    const iconClass = level === 'critical' ? '🔴' : '🟠';
    
    notice.innerHTML = `
      <span class="battery-notice-icon">${iconClass}</span>
      <span class="battery-notice-message">${message}</span>
      <button class="battery-notice-close">×</button>
    `;
    
    document.body.appendChild(notice);
    
    // Add close functionality
    const closeBtn = notice.querySelector('.battery-notice-close');
    closeBtn.addEventListener('click', () => {
      notice.classList.add('battery-notice-hiding');
      setTimeout(() => {
        if (notice.parentNode) {
          notice.parentNode.removeChild(notice);
        }
      }, 300);
    });
    
    // Auto-hide after 7 seconds
    setTimeout(() => {
      if (notice.parentNode && !notice.classList.contains('battery-notice-hiding')) {
        notice.classList.add('battery-notice-hiding');
        setTimeout(() => {
          if (notice.parentNode) {
            notice.parentNode.removeChild(notice);
          }
        }, 300);
      }
    }, 7000);
  }
  
  // Apply optimizations for low battery
  applyLowBatteryOptimizations() {
    document.documentElement.classList.add('disable-animations');
    
    // Reduce rendering complexity
    if (this.isLowEndDevice) {
      // For low-end devices in low battery situations, use extreme optimization
      this.applyExtremeOptimizations();
    }
  }
  
  // Apply extreme optimizations for very low-end devices or critical battery
  applyExtremeOptimizations() {
    // Remove non-essential elements
    document.querySelectorAll('.decorative, .visual-effect, .parallax, .non-essential').forEach(el => {
      el.style.display = 'none';
    });
    
    // Replace complex images with simple placeholders
    document.querySelectorAll('img:not(.essential)').forEach(img => {
      if (!img.dataset.originalSrc) {
        img.dataset.originalSrc = img.src;
        img.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"%3E%3C/svg%3E';
      }
    });
    
    // Disable background images
    document.querySelectorAll('[style*="background-image"]').forEach(el => {
      if (!el.dataset.originalBackgroundImage) {
        el.dataset.originalBackgroundImage = el.style.backgroundImage;
        el.style.backgroundImage = 'none';
      }
    });
  }
  
  // Restore optimizations when battery is charging or above threshold
  restoreFromOptimizations() {
    document.documentElement.classList.remove('disable-animations');
    
    // Restore elements
    document.querySelectorAll('[data-original-src]').forEach(img => {
      img.src = img.dataset.originalSrc;
    });
    
    document.querySelectorAll('[data-original-background-image]').forEach(el => {
      el.style.backgroundImage = el.dataset.originalBackgroundImage;
    });
  }
  
  // Setup device-specific rendering optimizations
  setupDeviceSpecificRendering() {
    if (!this.deviceInfo) return;
    
    const { type, os, generation, capabilities } = this.deviceInfo;
    
    // Apply different optimizations depending on device type
    this.applyDeviceTypeRendering(type);
    
    // Apply OS-specific optimizations
    if (os === 'ios') {
      this.applyIOSOptimizations();
    } else if (os === 'android') {
      this.applyAndroidOptimizations();
    }
    
    // Apply generation-specific optimizations
    if (generation === 'low-end') {
      this.applyLowEndOptimizations();
    } else if (generation === 'mid-range') {
      this.applyMidRangeOptimizations();
    }
    
    // Setup adaptive assets based on device capabilities
    this.setupAdaptiveAssets();
  }
  
  // Apply optimizations based on device type
  applyDeviceTypeRendering(deviceType) {
    if (deviceType === 'mobile') {
      // Mobile device optimizations
      document.querySelectorAll('.grid-complex').forEach(el => {
        el.style.display = 'flex';
        el.style.flexDirection = 'column';
      });
      
      // Optimize tap targets
      document.querySelectorAll('a, button, .clickable').forEach(el => {
        if (getComputedStyle(el).getPropertyValue('min-height') === 'auto' || 
            parseInt(getComputedStyle(el).getPropertyValue('min-height')) < 44) {
          el.style.minHeight = '44px';
        }
        
        if (getComputedStyle(el).getPropertyValue('min-width') === 'auto' || 
            parseInt(getComputedStyle(el).getPropertyValue('min-width')) < 44) {
          el.style.minWidth = '44px';
        }
      });
      
      // Optimize for smaller screens
      const smallScreenElements = document.querySelectorAll('.optimize-for-small-screen');
      smallScreenElements.forEach(el => {
        // Smaller font sizes
        const headings = el.querySelectorAll('h1, h2, h3, h4, h5, h6');
        headings.forEach(heading => {
          if (heading.tagName === 'H1') heading.style.fontSize = '1.75rem';
          if (heading.tagName === 'H2') heading.style.fontSize = '1.5rem';
          if (heading.tagName === 'H3') heading.style.fontSize = '1.25rem';
          if (heading.tagName === 'H4') heading.style.fontSize = '1.1rem';
        });
      });
    } else if (deviceType === 'tablet') {
      // Tablet-specific optimizations
      // Adjust panels and ui for tablets
      document.querySelectorAll('.side-panel').forEach(panel => {
        panel.style.width = '320px';
      });
    }
  }
  
  // Apply iOS-specific optimizations
  applyIOSOptimizations() {
    // Fix 100vh issue on iOS
    const setIOSHeight = () => {
      const vh = window.innerHeight * 0.01;
      document.documentElement.style.setProperty('--real-viewport-height', `${window.innerHeight}px`);
      document.documentElement.style.setProperty('--vh', `${vh}px`);
    };
    
    setIOSHeight();
    window.addEventListener('resize', setIOSHeight);
    
    // Add momentum scrolling to scrollable elements
    document.querySelectorAll('.scrollable').forEach(el => {
      el.style.webkitOverflowScrolling = 'touch';
    });
    
    // Address iOS keyboard issues
    const inputs = document.querySelectorAll('input, textarea');
    inputs.forEach(input => {
      input.addEventListener('focus', () => {
        document.documentElement.classList.add('keyboard-open');
        setTimeout(() => {
          window.scrollTo(0, 0);
        }, 300);
      });
      
      input.addEventListener('blur', () => {
        document.documentElement.classList.remove('keyboard-open');
      });
    });
    
    // iOS-specific terminal enhancements
    const terminal = document.querySelector('.terminal-container');
    if (terminal) {
      terminal.style.borderRadius = '8px';
      terminal.style.overflow = 'hidden';
      
      const terminalInput = terminal.querySelector('.terminal-input');
      if (terminalInput) {
        terminalInput.style.padding = '8px 0';
      }
    }
  }
  
  // Apply Android-specific optimizations
  applyAndroidOptimizations() {
    // Fix for some Android Chrome versions and overflow scrolling
    document.querySelectorAll('.scrollable').forEach(el => {
      el.style.backfaceVisibility = 'hidden';
      el.style.webkitBackfaceVisibility = 'hidden';
    });
    
    // Simplify transitions
    document.querySelectorAll('[style*="transition"]').forEach(el => {
      // Simplify any complex transitions to just opacity
      if (el.style.transition && !el.classList.contains('critical-animation')) {
        el.style.transitionProperty = 'opacity';
      }
    });
    
    // Android-specific terminal enhancements
    const terminal = document.querySelector('.terminal-container');
    if (terminal) {
      terminal.style.borderRadius = '4px';
      
      const terminalInputLine = terminal.querySelector('.terminal-input-line');
      if (terminalInputLine) {
        terminalInputLine.style.paddingTop = '4px';
      }
    }
  }
  
  // Apply optimizations for low-end devices
  applyLowEndOptimizations() {
    // Disable animations
    document.querySelectorAll('*').forEach(el => {
      if (getComputedStyle(el).getPropertyValue('animation-duration') !== '0s' && 
          !el.classList.contains('critical-animation')) {
        el.style.animationDuration = '0.01s';
        el.style.transitionDuration = '0.01s';
      }
    });
    
    // Remove shadows
    document.querySelectorAll('.card, .button, .panel, .shadow-effect').forEach(el => {
      el.style.boxShadow = 'none';
      if (!el.style.border) {
        el.style.border = '1px solid rgba(0, 0, 0, 0.1)';
      }
    });
    
    // Use simple solid colors instead of gradients
    document.querySelectorAll('[style*="background-image"]').forEach(el => {
      if (el.style.backgroundImage.includes('gradient') && !el.classList.contains('essential-gradient')) {
        el.style.backgroundImage = 'none';
      }
    });
    
    // Hide complex decorative elements
    document.querySelectorAll('.decorative, .visual-effect, .parallax').forEach(el => {
      el.style.display = 'none';
    });
    
    // Low-end terminal optimizations
    const terminal = document.querySelector('.terminal-container');
    if (terminal) {
      terminal.classList.add('terminal-low-end');
      
      // Optimized terminal header
      const terminalHeader = terminal.querySelector('.terminal-header');
      if (terminalHeader) {
        terminalHeader.style.background = 'var(--terminal-bg-color, #1a1a1a)';
        terminalHeader.style.borderBottom = '1px solid var(--terminal-border-color, #333)';
      }
      
      // Limit output rendering
      const terminalOutput = terminal.querySelector('.terminal-output');
      if (terminalOutput) {
        terminalOutput.style.maxHeight = '200px';
      }
      
      // Disable syntax highlighting for performance
      const syntaxHighlight = terminal.querySelectorAll('.syntax-highlight');
      syntaxHighlight.forEach(el => {
        el.style.color = 'inherit';
      });
    }
    
    // Use system fonts for better performance
    document.body.classList.add('use-system-fonts');
  }
  
  // Apply optimizations for mid-range devices
  applyMidRangeOptimizations() {
    // Moderate visual simplification
    document.querySelectorAll('.complex-animation').forEach(el => {
      const currentDuration = getComputedStyle(el).getPropertyValue('animation-duration');
      if (currentDuration !== '0s') {
        const durationValue = parseFloat(currentDuration);
        const unit = currentDuration.replace(/[\d.]/g, '');
        el.style.animationDuration = (durationValue * 0.5) + unit; // Halve animation time
      }
    });
    
    // Lightweight shadows
    document.querySelectorAll('.card, .button, .panel, .shadow-effect').forEach(el => {
      el.style.boxShadow = '0 1px 3px rgba(0, 0, 0, 0.1)';
    });
    
    // Basic gradients
    document.querySelectorAll('.complex-gradient').forEach(el => {
      el.style.backgroundImage = 'linear-gradient(to bottom, var(--gradient-start, #fff), var(--gradient-end, #eee))';
    });
    
    // Terminal-specific optimizations for mid-range devices
    const terminal = document.querySelector('.terminal-container');
    if (terminal) {
      const terminalHeader = terminal.querySelector('.terminal-header');
      if (terminalHeader) {
        terminalHeader.style.boxShadow = 'none';
      }
    }
  }
  
  // Setup adaptive assets based on device capabilities
  setupAdaptiveAssets() {
    if (!this.deviceInfo) return;
    
    const { generation, capabilities } = this.deviceInfo;
    
    // Adaptive image loading based on device capabilities
    document.querySelectorAll('img[data-src-low], img[data-src-high]').forEach(img => {
      if (generation === 'low-end') {
        // Use lower resolution for low-end devices
        if (img.dataset.srcLow) {
          img.src = img.dataset.srcLow;
        }
      } else {
        // Use high resolution for better devices
        if (img.dataset.srcHigh) {
          img.src = img.dataset.srcHigh;
        }
      }
    });
    
    // Adaptive background images
    document.querySelectorAll('[data-bg-low], [data-bg-high]').forEach(el => {
      if (generation === 'low-end') {
        if (el.dataset.bgLow) {
          el.style.backgroundImage = `url(${el.dataset.bgLow})`;
        }
      } else {
        if (el.dataset.bgHigh) {
          el.style.backgroundImage = `url(${el.dataset.bgHigh})`;
        }
      }
    });
    
    // Adaptive features
    if (generation === 'low-end') {
      // Disable non-essential features
      document.querySelectorAll('.feature-high-end').forEach(el => {
        el.style.display = 'none';
      });
    } else if (generation === 'high-end') {
      // Enable advanced features
      document.querySelectorAll('.feature-high-end').forEach(el => {
        el.style.display = '';
      });
    }
  }
  
  // Setup lazy loading for images and other heavy content
  setupLazyLoading() {
    if (!('IntersectionObserver' in window)) {
      // Fallback for browsers without IntersectionObserver
      this.loadAllLazyContent();
      return;
    }
    
    const lazyImages = document.querySelectorAll('img[data-src], [data-background-src], .defer-load');
    
    const lazyLoadObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const lazyElement = entry.target;
          
          if (lazyElement.tagName === 'IMG') {
            if (lazyElement.dataset.src) {
              lazyElement.src = lazyElement.dataset.src;
              lazyElement.classList.add('loaded');
            }
          } else if (lazyElement.dataset.backgroundSrc) {
            lazyElement.style.backgroundImage = `url(${lazyElement.dataset.backgroundSrc})`;
            lazyElement.classList.add('loaded');
          } else if (lazyElement.classList.contains('defer-load')) {
            // Custom handling for other deferred content
            this.loadDeferredContent(lazyElement);
          }
          
          // Stop observing after loading
          lazyLoadObserver.unobserve(lazyElement);
        }
      });
    }, {
      rootMargin: '100px' // Load when within 100px of viewport
    });
    
    lazyImages.forEach(lazyElement => {
      lazyLoadObserver.observe(lazyElement);
    });
  }
  
  // Load all lazy content at once (fallback)
  loadAllLazyContent() {
    document.querySelectorAll('img[data-src]').forEach(img => {
      img.src = img.dataset.src;
    });
    
    document.querySelectorAll('[data-background-src]').forEach(el => {
      el.style.backgroundImage = `url(${el.dataset.backgroundSrc})`;
    });
    
    document.querySelectorAll('.defer-load').forEach(el => {
      this.loadDeferredContent(el);
    });
  }
  
  // Load deferred content (non-image)
  loadDeferredContent(element) {
    element.classList.add('loaded');
    
    // If it has deferred HTML content
    if (element.dataset.html) {
      element.innerHTML = element.dataset.html;
    }
    
    // If it has a callback function
    if (element.dataset.callback) {
      try {
        const callback = new Function('return ' + element.dataset.callback)();
        callback(element);
      } catch (error) {
        console.error('Error executing callback for deferred content:', error);
      }
    }
  }
}

// Create and export an instance
const mobileOptimizations = new MobileOptimizations();
export default mobileOptimizations; 