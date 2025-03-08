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

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Import component hooks
import DebugGrid from "./components/debug_grid"
import ThemeToggle from "./components/theme_toggle"
import { CharacterAnimation, GridFadeIn } from "./components/animations"

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

// Connect to LiveView
liveSocket.connect()

// Initialize theme from localStorage on page load
document.addEventListener('DOMContentLoaded', () => {
  const savedTheme = localStorage.getItem('theme') || 'dark-theme'
  document.documentElement.className = savedTheme
  document.body.classList.add(savedTheme)
})

// Expose liveSocket for debugging in development
window.liveSocket = liveSocket

