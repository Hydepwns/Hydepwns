/**
 * Core Component System
 * 
 * This file exports the core modules of the Hydepwns Enhanced Component System.
 * Import from this file to access the complete component system.
 */

import HydeComponent from './component_base';
import Registry from './component_registry';
import EventBus from './event_bus';
import StateManager, { reactive } from './reactive_state';
import { 
  registerComponent, 
  withContext, 
  withTags, 
  debugComponent, 
  composeDecorators 
} from './decorators';

// Import Inspector modules
import InspectorUI from '../inspector/inspector_ui';
import PerformanceMonitor from '../inspector/performance_monitor';
import EventMonitor from '../inspector/event_monitor';
import ComponentTree from '../inspector/component_tree';

// Create Inspector namespace
const Inspector = {
  UI: InspectorUI,
  PerformanceMonitor,
  EventMonitor,
  ComponentTree
};

// Export all core modules
export {
  // Base component
  HydeComponent,
  
  // Core systems
  Registry,
  EventBus,
  StateManager,
  reactive,
  
  // Decorators
  registerComponent,
  withContext,
  withTags,
  debugComponent,
  composeDecorators,
  
  // Inspector
  Inspector
};

// Default export for convenience
export default {
  HydeComponent,
  Registry,
  EventBus,
  StateManager,
  reactive,
  registerComponent,
  withContext,
  withTags,
  debugComponent,
  composeDecorators,
  Inspector
}; 