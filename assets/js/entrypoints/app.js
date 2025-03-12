// Main application entry point

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../../vendor/topbar"

// Import service worker registration
import { initServiceWorker } from "../service-worker-registration"

// Import performance optimizations
import MobilePerformance from "../performance/mobile_optimizations"
import CodeSplitting from "../performance/code_splitting"
import TerminalMobileOptimizations from "../terminal_mobile_optimizations"

// Import core hooks that should be available across all pages
import DebugGrid from "../hooks/debug_grid"
import ThemeToggle from "../hooks/theme_toggle"
import KeyboardNavigation from "../hooks/keyboard_navigation"
import FocusMode from "../hooks/focus_mode"
import AutoResize from "../hooks/auto_resize"
import MonoGrid from "../hooks/mono_grid"
import { DismissibleInfoBox } from "../hooks/info_box_hooks"
import { MonoTabs } from "../hooks/mono_tabs_hooks"

// Import accessibility functions
import "../accessibility/accessibility.js"

// Import font optimization module
import { initFontOptimizations } from "../font-optimizations";

/**
 * Debug Utility
 */
const debug = {
  log(...args) {
    if (window.hydepwnsDebug) {
      console.log("HYDEPWNS DEBUG:", ...args);
    }
  }
};

// Define LiveView hooks
const Hooks = {
  DebugGrid,
  ThemeToggle,
  KeyboardNavigation,
  FocusMode,
  AutoResize,
  MonoGrid,
  DismissibleInfoBox,
  MonoTabs
};

// Check if we're on a mobile device for performance optimizations
const isMobileDevice = () => {
  return (window.innerWidth <= 768) || 
         (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent));
};

// Initialize LiveSocket with performance optimizations for mobile
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocketOptions = {
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      // Keep the scroll position when the DOM is updated
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }

      // Preserve the focus state for interactive elements
      if (from.matches("button, a, input, select, textarea") && from === document.activeElement) {
        window.requestAnimationFrame(() => {
          to.focus();
        });
      }
    }
  }
};

// Apply mobile-specific optimizations to LiveSocket if needed
if (isMobileDevice()) {
  // Throttle events for better performance on mobile
  liveSocketOptions.throttle = {
    events: {
      mousemove: 50,    // Update every 50ms at most during mouse moves
      scroll: 100       // Update every 100ms at most during scrolls
    }
  };
  
  // Use simpler animations
  liveSocketOptions.transitions = {
    default: {
      onStart: function() { },
      onDone: function() { }
    }
  };
}

let liveSocket = new LiveSocket("/live", Socket, liveSocketOptions);

// Configure progress bar for better mobile performance
topbar.config({
  barColors: {0: "#29d"}, 
  shadowColor: "rgba(0, 0, 0, .3)",
  barThickness: isMobileDevice() ? 2 : 3,  // Thinner bar on mobile
  shadowBlur: isMobileDevice() ? 4 : 10    // Less blur on mobile
});

// Show progress bar on live navigation and form submissions
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

// Connect if there are any LiveViews on the page
liveSocket.connect();

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Set the initial theme on page load
const setInitialTheme = () => {
  const storedTheme = localStorage.getItem('theme');
  const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  
  // Apply the appropriate theme
  if (storedTheme) {
    document.body.classList.add(storedTheme);
  } else if (systemPrefersDark) {
    document.body.classList.add('dark-theme');
  } else {
    document.body.classList.add('light-theme');
  }
};

// Apply font optimizations
initFontOptimizations();

// Initialize service worker
initServiceWorker();

// Initialize application with performance optimizations
document.addEventListener("DOMContentLoaded", function() {
  setInitialTheme();
  
  // Apply mobile performance optimizations
  if (isMobileDevice()) {
    document.body.classList.add('mobile-device');
    
    // Initialize mobile performance optimizations
    MobilePerformance.init();
    
    // Initialize terminal-specific optimizations for mobile
    TerminalMobileOptimizations.init();
  }
  
  // Initialize code splitting for all devices
  // (handles dynamic loading based on need)
  CodeSplitting.init();
  
  // Dynamically load route-specific bundles
  // (this is now handled by CodeSplitting for better performance)
  if (!isMobileDevice()) {
    // Only use old method for non-mobile devices
    loadRouteSpecificBundle();
  }
});

/**
 * Load route-specific JavaScript bundles based on the current URL path
 * Note: This is the legacy method, prefer using CodeSplitting for new code
 */
function loadRouteSpecificBundle() {
  const path = window.location.pathname;
  
  // Map paths to their respective bundles
  if (path.startsWith('/style-guide')) {
    import('../routes/style_guide')
      .then(module => {
        console.log('Style guide bundle loaded');
      })
      .catch(error => {
        console.error('Failed to load style guide bundle:', error);
      });
  } 
  else if (path.startsWith('/ascii')) {
    import('../routes/ascii')
      .then(module => {
        console.log('ASCII art bundle loaded');
      })
      .catch(error => {
        console.error('Failed to load ASCII bundle:', error);
      });
  }
  else if (path.startsWith('/terminal')) {
    import('../routes/terminal')
      .then(module => {
        console.log('Terminal bundle loaded');
        // Initialize terminal optimizations even on non-mobile devices
        // when visiting the terminal pages
        import('../terminal_mobile_optimizations')
          .then(terminalModule => {
            terminalModule.default.init();
          })
          .catch(error => {
            console.error('Failed to load terminal optimizations:', error);
          });
      })
      .catch(error => {
        console.error('Failed to load terminal bundle:', error);
      });
  }
  else if (path.startsWith('/grid-playground')) {
    import('../routes/grid_playground')
      .then(module => {
        console.log('Grid playground bundle loaded');
      })
      .catch(error => {
        console.error('Failed to load grid playground bundle:', error);
      });
  }
}

// Export common utilities for use in other modules
export {
  liveSocket,
  Hooks,
  debug,
  MobilePerformance,
  CodeSplitting
}; 