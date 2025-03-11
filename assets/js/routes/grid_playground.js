/**
 * Grid Playground Route Bundle
 * 
 * This file contains all JavaScript that's specific to the grid playground route.
 * It's loaded dynamically only when a user visits the grid playground page.
 */
import { liveSocket, Hooks } from '../entrypoints/app';
import MonoGrid from "../hooks/mono_grid";
import CopyableCode from "../hooks/copyable_code";
import DiagramEditor from "../hooks/diagram_editor";

// Register route-specific hooks
Hooks.MonoGrid = MonoGrid;
Hooks.CopyableCode = CopyableCode;
Hooks.DiagramEditor = DiagramEditor;

// Update the LiveSocket with new hooks
liveSocket.updateHooks(Hooks);

// Initialize grid playground specific functionality
console.log('Initializing grid playground specific functionality');

// Grid example templates
const gridExamples = {
  basic: {
    rows: 3,
    cols: 40,
    cells: [
      { row: 1, col: 1, colspan: 40, content: "Header spanning full width" },
      { row: 2, col: 1, colspan: 20, content: "Left column" },
      { row: 2, col: 21, colspan: 20, content: "Right column" },
      { row: 3, col: 1, colspan: 40, content: "Footer spanning full width" }
    ]
  },
  
  table: {
    rows: 4,
    cols: 40,
    bordered: true,
    cells: [
      { row: 1, col: 1, colspan: 10, content: "ID", align: "center" },
      { row: 1, col: 11, colspan: 20, content: "Name", align: "center" },
      { row: 1, col: 31, colspan: 10, content: "Value", align: "center" },
      { row: 2, col: 1, colspan: 10, content: "1", align: "center" },
      { row: 2, col: 11, colspan: 20, content: "Item One" },
      { row: 2, col: 31, colspan: 10, content: "$10.00", align: "right" },
      { row: 3, col: 1, colspan: 10, content: "2", align: "center" },
      { row: 3, col: 11, colspan: 20, content: "Item Two" },
      { row: 3, col: 31, colspan: 10, content: "$15.50", align: "right" },
      { row: 4, col: 1, colspan: 30, content: "Total", align: "right" },
      { row: 4, col: 31, colspan: 10, content: "$25.50", align: "right" }
    ]
  },
  
  ascii: {
    rows: 7,
    cols: 40,
    cells: [
      { row: 1, col: 1, colspan: 40, content: "┌──────────────────────────────────────┐" },
      { row: 2, col: 1, colspan: 40, content: "│           ASCII Art Example          │" },
      { row: 3, col: 1, colspan: 40, content: "├──────────────────────────────────────┤" },
      { row: 4, col: 1, colspan: 40, content: "│    /\\   /\\                           │" },
      { row: 5, col: 1, colspan: 40, content: "│   /  \\ /  \\     Monospace ASCII      │" },
      { row: 6, col: 1, colspan: 40, content: "│   \\__/ \\__/       is awesome!        │" },
      { row: 7, col: 1, colspan: 40, content: "└──────────────────────────────────────┘" }
    ]
  }
};

// Make functions available globally if needed
window.gridPlayground = {
  examples: gridExamples,
  loadExample: (name) => {
    // This function would be called from the LiveView
    // to load an example template
    if (gridExamples[name]) {
      return gridExamples[name];
    }
    return null;
  }
};

// Export hooks and utilities for potential use in other modules
export { Hooks, gridExamples }; 