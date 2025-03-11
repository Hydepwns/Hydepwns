// Main application entry point

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../../vendor/topbar"

// Import service worker registration
import { initServiceWorker } from "../service-worker-registration"

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

// Initialize LiveSocket
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
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
});

// Show progress bar on live navigation and form submissions
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"});
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

// Initialize application
document.addEventListener("DOMContentLoaded", function() {
  setInitialTheme();
  
  // Dynamically load route-specific bundles
  loadRouteSpecificBundle();
});

/**
 * Load route-specific JavaScript bundles based on the current URL path
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
  debug
}; 