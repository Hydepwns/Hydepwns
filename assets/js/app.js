import './components/auto_resize.js';
import './components/accessibility_menu_toggle.js';
import './components/ascii_art_generator.js';
import './components/copyable_code.js';
import './components/info_box.js';
import './components/keyboard_navigation.js';
import './components/mono_grid.js';
import './components/mono_tabs.js';
import './components/notifications.js';
import './components/toast.js';
import './components/viewport_detector.js';
import './utils/dom_cleanup.js';
import './event_manager.js';
import ThemeHooks from "./theme_hooks.js";

import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

let Hooks = {};
Hooks.ThemeToggle = ThemeHooks;

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken}
});

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