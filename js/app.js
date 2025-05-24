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

window.phxLiveViewPids = window.phxLiveViewPids || [];
window.addEventListener("phx:live_view_pid", (e) => {
  window.phxLiveViewPids.push(e.detail.pid);
}); 