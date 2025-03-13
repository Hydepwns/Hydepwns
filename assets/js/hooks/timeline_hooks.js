/**
 * Timeline Hook
 * Provides interactive functionality for the monospace timeline component.
 * 
 * Features:
 * - Handles animation of timeline elements
 * - Supports keyboard navigation between timeline events
 * - Implements accessibility features
 * - Optimizes performance with IntersectionObserver
 */

import { TimelineComponent } from '../components/timeline';

const TimelineHook = {
  mounted() {
    // Create and mount the TimelineComponent
    this.component = new TimelineComponent({
      liveViewHook: this,
      debug: this.el.hasAttribute('data-debug')
    }).mount();
  },
  
  // Replayy animation (can be called from LiveView)
  replayAnimation() {
    if (this.component) {
      this.component.replayAnimation();
    }
  },
  
  // Focus a specific timeline item (can be called from LiveView)
  focusTimelineItem(index) {
    if (this.component) {
      this.component.focusItem(index);
    }
  },
  
  destroyed() {
    // Clean up the component
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default TimelineHook; 