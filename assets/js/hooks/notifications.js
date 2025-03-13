/**
 * JavaScript hook for handling notifications
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the NotificationsComponent.
 * 
 * @see ../components/notifications.js for the full implementation
 */
import { NotificationsComponent } from '../components/notifications';

const NotificationsHandler = {
  mounted() {
    this.component = new NotificationsComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    if (this.component) {
      this.component.update();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  },
  
  handleEvent(event, payload) {
    if (event === "updated_notifications" && this.component) {
      this.component.update();
    }
  }
};

export default NotificationsHandler; 