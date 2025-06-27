// import './components/auto_resize.js';
// import './components/accessibility_menu_toggle.js';
// import './components/ascii_art_generator.js';
// import './components/copyable_code.js';
// import './components/info_box.js';
// import './components/keyboard_navigation.js';
// import './components/mono_grid.js';
// import './components/mono_tabs.js';
import './components/notifications.js';
// import './components/toast.js';
// import './components/viewport_detector.js';
import './utils/dom_cleanup.js';
import './event_manager.js';
import './component_loader.js';
import ThemeHooks from "./theme_hooks.js";
import { NotificationsComponent, NotificationItem } from "./components/notifications.js";

import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

let Hooks = {};
Hooks.ThemeToggle = ThemeHooks;
Hooks.NotificationsHandler = NotificationsComponent;
Hooks.NotificationItem = NotificationItem;

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken}
});

// Comprehensive patch for invalid selectors
if (liveSocket.dom) {
  const originalFilterToEls = liveSocket.dom.filterToEls;
  liveSocket.dom.filterToEls = function(liveSocket2, sourceEl, { to }) {
    // Validate the selector before using it
    if (typeof to === "string" && (to === "#" || to === "" || !to || to === "undefined" || to === "null")) {
      console.warn("Invalid selector detected:", to, "falling back to source element");
      return [sourceEl];
    }
    return originalFilterToEls.call(this, liveSocket2, sourceEl, { to });
  };
}

// Also patch the global querySelectorAll function to handle invalid selectors
const originalQuerySelectorAll = document.querySelectorAll;
document.querySelectorAll = function(selector) {
  if (typeof selector === "string" && (selector === "#" || selector === "" || !selector || selector === "undefined" || selector === "null")) {
    console.warn("Invalid querySelectorAll selector:", selector, "returning empty NodeList");
    return document.createDocumentFragment().querySelectorAll("*"); // Return empty NodeList
  }
  return originalQuerySelectorAll.call(this, selector);
};

liveSocket.connect();

window.liveSocket = liveSocket;

// Ensure window.phxLiveViewPids and event listener are present (from old top-level app.js)
if (!window.phxLiveViewPids) {
  window.phxLiveViewPids = [];
}
if (!window.phxLiveViewPidsListenerAdded) {
  window.addEventListener("phx:live_view_pid", (e) => {
    window.phxLiveViewPids.push(e.detail.pid);
  });
  window.phxLiveViewPidsListenerAdded = true;
} 