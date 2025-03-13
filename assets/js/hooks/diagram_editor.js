/**
 * Diagram Editor Hook
 * ------------------
 * This hook provides the JavaScript functionality for the ASCII diagram editor component.
 * 
 * This hook has been updated to use the class-based DiagramEditorComponent 
 * for better organization, isolation, and resource management.
 */

import { DiagramEditorComponent } from '../components/diagram_editor';

const DiagramEditor = {
  mounted() {
    this.component = new DiagramEditorComponent({
      container: this.el,
      liveViewHook: this
    }).mount();
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default DiagramEditor; 