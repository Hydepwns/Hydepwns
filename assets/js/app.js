// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Remove CSS imports - now handled by Phoenix's built-in CSS processing

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Import component hooks
import DebugGrid from "./hooks/debug_grid"
import ThemeToggle from "./hooks/theme_toggle"
import { CharacterAnimation, GridFadeIn } from "./components/animations"

/**
 * Debug Utility
 * -------------
 * Provides controlled logging that only appears in development environments.
 * 
 * This utility prevents debug logs from appearing in production while maintaining
 * useful development information. All component logging should use this utility
 * instead of direct console.log calls.
 * 
 * Usage: DEBUG.log("Message", value1, value2, ...);
 */
const DEBUG = {
  enabled: window.location.hostname === 'localhost',
  log(...args) {
    if (this.enabled) console.log(...args);
  }
};

// Initialize Phoenix LiveView
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Register all component hooks
const Hooks = {
  DebugGridToggle: DebugGrid,
  ThemeToggle: ThemeToggle,
  CharacterAnimation: CharacterAnimation,
  GridFadeIn: GridFadeIn
}

// Create LiveSocket with hooks
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Configure page loading indicators
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

/**
 * Theme System: Initial Setup
 * ---------------------------
 * This function runs immediately to set the initial theme before DOM is fully loaded,
 * which prevents a flash of unstyled content or incorrect theme on page load.
 * 
 * The theme is applied in two ways:
 * 1. As a data-theme attribute on documentElement (html tag) - This enables CSS
 *    variables to be inherited throughout the document.
 * 2. As a class on the body element - This enables class-based styling for specific
 *    elements and components.
 * 
 * The function prioritizes themes in this order:
 * 1. User's previously selected theme from localStorage
 * 2. System preference (light/dark) if no saved preference
 * 3. Light theme as fallback
 */
const setInitialTheme = () => {
  DEBUG.log("Setting initial theme on page load");
  
  // Check system preference or use saved theme
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const savedTheme = localStorage.getItem('theme') || (prefersDark ? 'dark-theme' : 'light-theme');
  
  DEBUG.log("Initial theme value", savedTheme);
  
  // Apply to document and body
  document.documentElement.setAttribute('data-theme', savedTheme);
  document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
  document.body.classList.add(savedTheme);
  
  // Log result for debugging
  DEBUG.log("Theme applied to document element:", document.documentElement.getAttribute('data-theme'));
  DEBUG.log("Theme applied to body:", document.body.className);
};

// Run immediately without waiting for DOMContentLoaded
setInitialTheme();

// Also run when DOM is loaded as a fallback
document.addEventListener('DOMContentLoaded', setInitialTheme);

// Connect to LiveView
liveSocket.connect()

// Expose liveSocket and debug utility for debugging in development
window.liveSocket = liveSocket
window.DEBUG = DEBUG

