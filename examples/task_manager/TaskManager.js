/**
 * TaskManager Component
 * 
 * This example demonstrates:
 * 1. Reactive state management
 * 2. Computed properties
 * 3. Component Inspector integration
 * 4. Performance optimization techniques
 */

import { 
  HydeComponent, 
  StateManager, 
  debugComponent,
  Inspector
} from '../../assets/js/components/core';

// Enable the component inspector in development
if (process.env.NODE_ENV !== 'production') {
  const inspector = new Inspector.UI({
    position: 'bottom-right',
    theme: 'dark'
  });
  inspector.enable();
}

/**
 * Task Manager Component
 * Demonstrates reactive state system and component inspector integration
 */
@debugComponent
export default class TaskManager extends HydeComponent {
  constructor(options = {}) {
    super(options);
    
    // Initialize the component
    this.name = 'TaskManager';
    this.element = options.container || document.createElement('div');
    this.element.className = 'task-manager';
    
    // Initialize state manager with history for debugging
    this.stateManager = new StateManager({
      updateCallback: () => this.render(),
      historyEnabled: true
    });
    
    // Define reactive state
    this.state = this.stateManager.defineState({
      tasks: [
        { id: 1, title: 'Learn reactive state', completed: false, priority: 'high' },
        { id: 2, title: 'Build task manager', completed: false, priority: 'medium' },
        { id: 3, title: 'Write tests', completed: false, priority: 'medium' }
      ],
      newTaskTitle: '',
      filter: 'all', // 'all', 'active', 'completed'
      sortBy: 'id',  // 'id', 'title', 'priority'
      sortDirection: 'asc'
    });
    
    // Define computed properties
    this.stateManager.compute('filteredTasks', ['tasks', 'filter'], (state) => {
      const { tasks, filter } = state;
      
      if (filter === 'all') return tasks;
      return tasks.filter(task => 
        filter === 'completed' ? task.completed : !task.completed
      );
    });
    
    this.stateManager.compute('sortedTasks', ['filteredTasks', 'sortBy', 'sortDirection'], (state) => {
      const { filteredTasks, sortBy, sortDirection } = state;
      
      // Create a copy to avoid modifying the original array
      const sorted = [...filteredTasks];
      
      return sorted.sort((a, b) => {
        const valueA = a[sortBy];
        const valueB = b[sortBy];
        
        if (typeof valueA === 'string') {
          return sortDirection === 'asc' 
            ? valueA.localeCompare(valueB) 
            : valueB.localeCompare(valueA);
        }
        
        return sortDirection === 'asc' 
          ? valueA - valueB 
          : valueB - valueA;
      });
    });
    
    this.stateManager.compute('completedCount', ['tasks'], (state) => {
      return state.tasks.filter(task => task.completed).length;
    });
    
    this.stateManager.compute('activeCount', ['tasks'], (state) => {
      return state.tasks.filter(task => !task.completed).length;
    });
    
    this.stateManager.compute('totalCount', ['tasks'], (state) => {
      return state.tasks.length;
    });
    
    // Initial render
    this.render();
    
    // Register performance monitoring (in development only)
    if (process.env.NODE_ENV !== 'production') {
      this.perfMonitor = new Inspector.PerformanceMonitor();
      this._registerDebugHelpers();
    }
  }
  
  /**
   * Add a new task
   */
  addTask() {
    if (!this.state.newTaskTitle.trim()) return;
    
    // Start measuring performance if available
    if (this.perfMonitor) {
      this.perfMonitor.startMeasurement(this.id, 'addTask');
    }
    
    // Generate a unique ID
    const maxId = Math.max(0, ...this.state.tasks.map(task => task.id));
    
    // Add the new task using batch to prevent multiple renders
    this.stateManager.batch(() => {
      this.state.tasks.push({
        id: maxId + 1,
        title: this.state.newTaskTitle,
        completed: false,
        priority: 'medium'
      });
      
      this.state.newTaskTitle = '';
    });
    
    // End performance measurement
    if (this.perfMonitor) {
      this.perfMonitor.endMeasurement(this.id, 'addTask');
    }
  }
  
  /**
   * Toggle task completion
   * @param {Number} id - Task ID
   */
  toggleTask(id) {
    const taskIndex = this.state.tasks.findIndex(task => task.id === id);
    if (taskIndex !== -1) {
      this.state.tasks[taskIndex].completed = !this.state.tasks[taskIndex].completed;
    }
  }
  
  /**
   * Update task priority
   * @param {Number} id - Task ID
   * @param {String} priority - Task priority
   */
  updatePriority(id, priority) {
    const taskIndex = this.state.tasks.findIndex(task => task.id === id);
    if (taskIndex !== -1) {
      this.state.tasks[taskIndex].priority = priority;
    }
  }
  
  /**
   * Delete a task
   * @param {Number} id - Task ID
   */
  deleteTask(id) {
    const taskIndex = this.state.tasks.findIndex(task => task.id === id);
    if (taskIndex !== -1) {
      this.state.tasks.splice(taskIndex, 1);
    }
  }
  
  /**
   * Set the active filter
   * @param {String} filter - Filter value
   */
  setFilter(filter) {
    this.state.filter = filter;
  }
  
  /**
   * Set sorting options
   * @param {String} sortBy - Field to sort by
   */
  setSorting(sortBy) {
    // If already sorting by this field, toggle direction
    if (this.state.sortBy === sortBy) {
      this.state.sortDirection = this.state.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.state.sortBy = sortBy;
      this.state.sortDirection = 'asc';
    }
  }
  
  /**
   * Render the component
   */
  render() {
    // Start measuring render performance if available
    if (this.perfMonitor) {
      this.perfMonitor.startMeasurement(this.id, 'render');
    }
    
    // Create the HTML structure
    let html = `
      <div class="task-manager-header">
        <h1>Task Manager</h1>
        <div class="task-stats">
          <span>${this.state.activeCount} active</span>
          <span>${this.state.completedCount} completed</span>
          <span>${this.state.totalCount} total</span>
        </div>
      </div>
      
      <div class="task-form">
        <input 
          type="text" 
          class="task-input" 
          placeholder="Add a new task..." 
          value="${this.state.newTaskTitle}"
        >
        <button class="task-add-btn">Add Task</button>
      </div>
      
      <div class="task-filters">
        <button class="filter-btn ${this.state.filter === 'all' ? 'active' : ''}" data-filter="all">All</button>
        <button class="filter-btn ${this.state.filter === 'active' ? 'active' : ''}" data-filter="active">Active</button>
        <button class="filter-btn ${this.state.filter === 'completed' ? 'active' : ''}" data-filter="completed">Completed</button>
      </div>
      
      <div class="task-sort">
        <span>Sort by:</span>
        <button class="sort-btn ${this.state.sortBy === 'id' ? 'active' : ''}" data-sort="id">ID ${this._getSortIndicator('id')}</button>
        <button class="sort-btn ${this.state.sortBy === 'title' ? 'active' : ''}" data-sort="title">Title ${this._getSortIndicator('title')}</button>
        <button class="sort-btn ${this.state.sortBy === 'priority' ? 'active' : ''}" data-sort="priority">Priority ${this._getSortIndicator('priority')}</button>
      </div>
      
      <ul class="task-list">
    `;
    
    // Render each task
    if (this.state.sortedTasks.length === 0) {
      html += `<li class="task-empty">No tasks to display</li>`;
    } else {
      this.state.sortedTasks.forEach(task => {
        html += `
          <li class="task-item ${task.completed ? 'completed' : ''}" data-id="${task.id}">
            <div class="task-item-header">
              <input type="checkbox" class="task-checkbox" ${task.completed ? 'checked' : ''}>
              <span class="task-title">${task.title}</span>
            </div>
            <div class="task-item-actions">
              <select class="task-priority" data-id="${task.id}">
                <option value="low" ${task.priority === 'low' ? 'selected' : ''}>Low</option>
                <option value="medium" ${task.priority === 'medium' ? 'selected' : ''}>Medium</option>
                <option value="high" ${task.priority === 'high' ? 'selected' : ''}>High</option>
              </select>
              <button class="task-delete" data-id="${task.id}">Delete</button>
            </div>
          </li>
        `;
      });
    }
    
    html += `
      </ul>
      
      ${this._renderDebugPanel()}
    `;
    
    this.element.innerHTML = html;
    
    // Attach event handlers
    this._attachEventHandlers();
    
    // End render performance measurement
    if (this.perfMonitor) {
      this.perfMonitor.endMeasurement(this.id, 'render');
    }
  }
  
  /**
   * Attach event handlers to DOM elements
   * @private
   */
  _attachEventHandlers() {
    // Add task form
    const input = this.element.querySelector('.task-input');
    const addBtn = this.element.querySelector('.task-add-btn');
    
    input.addEventListener('input', (e) => {
      this.state.newTaskTitle = e.target.value;
    });
    
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') this.addTask();
    });
    
    addBtn.addEventListener('click', () => this.addTask());
    
    // Task checkboxes
    this.element.querySelectorAll('.task-checkbox').forEach(checkbox => {
      const taskId = parseInt(checkbox.closest('.task-item').dataset.id);
      checkbox.addEventListener('change', () => this.toggleTask(taskId));
    });
    
    // Delete buttons
    this.element.querySelectorAll('.task-delete').forEach(btn => {
      const taskId = parseInt(btn.dataset.id);
      btn.addEventListener('click', () => this.deleteTask(taskId));
    });
    
    // Priority selects
    this.element.querySelectorAll('.task-priority').forEach(select => {
      const taskId = parseInt(select.dataset.id);
      select.addEventListener('change', (e) => this.updatePriority(taskId, e.target.value));
    });
    
    // Filter buttons
    this.element.querySelectorAll('.filter-btn').forEach(btn => {
      btn.addEventListener('click', () => this.setFilter(btn.dataset.filter));
    });
    
    // Sort buttons
    this.element.querySelectorAll('.sort-btn').forEach(btn => {
      btn.addEventListener('click', () => this.setSorting(btn.dataset.sort));
    });
    
    // Debug buttons (if present)
    const timeTravel = this.element.querySelector('.debug-time-travel');
    if (timeTravel) {
      timeTravel.addEventListener('change', (e) => {
        this.stateManager.revertToState(parseInt(e.target.value));
      });
    }
  }
  
  /**
   * Get sort indicator for column headers
   * @param {String} field - Field name
   * @returns {String} Sort indicator
   * @private
   */
  _getSortIndicator(field) {
    if (this.state.sortBy !== field) return '';
    return this.state.sortDirection === 'asc' ? '↑' : '↓';
  }
  
  /**
   * Register additional debug helpers
   * @private
   */
  _registerDebugHelpers() {
    // Track key statistics for the component
    this.perfMonitor.trackStatistic(this.id, 'taskCount', () => this.state.tasks.length);
    
    // Watch for filter changes for analytics
    this.stateManager.watch('filter', (newFilter) => {
      console.log(`Filter changed to: ${newFilter}`);
      this.perfMonitor.recordEvent(this.id, 'filterChange', { filter: newFilter });
    });
  }
  
  /**
   * Render debug panel (in development mode)
   * @returns {String} Debug panel HTML
   * @private
   */
  _renderDebugPanel() {
    if (process.env.NODE_ENV !== 'production' && this.stateManager._historyEnabled) {
      const history = this.stateManager.getHistory();
      
      let html = `
        <div class="task-debug-panel">
          <h3>Debug Panel</h3>
          <div class="debug-section">
            <h4>State History</h4>
            <select class="debug-time-travel">
              <option value="-1">Current State</option>
      `;
      
      history.forEach((change, index) => {
        html += `<option value="${index}">Change ${index + 1}: ${change.path} = ${JSON.stringify(change.newValue)}</option>`;
      });
      
      html += `
            </select>
          </div>
          
          <div class="debug-section">
            <h4>Performance</h4>
            <div class="debug-performance">
              ${this._renderPerformanceInfo()}
            </div>
          </div>
        </div>
      `;
      
      return html;
    }
    
    return '';
  }
  
  /**
   * Render performance information
   * @returns {String} Performance info HTML
   * @private
   */
  _renderPerformanceInfo() {
    if (!this.perfMonitor) return 'Performance monitoring not available';
    
    const metrics = this.perfMonitor.getMetrics(this.id);
    if (!metrics) return 'No metrics collected yet';
    
    let html = '<ul>';
    
    Object.entries(metrics).forEach(([operation, data]) => {
      html += `
        <li>
          <strong>${operation}:</strong> 
          ${data.lastDuration ? data.lastDuration.toFixed(2) + 'ms' : 'N/A'} 
          (avg: ${data.average ? data.average.toFixed(2) + 'ms' : 'N/A'})
        </li>
      `;
    });
    
    html += '</ul>';
    return html;
  }
  
  /**
   * Cleanup resources when component is destroyed
   */
  destroy() {
    // Clean up event listeners, subscriptions, etc.
    if (this.element.parentNode) {
      this.element.parentNode.removeChild(this.element);
    }
    
    // Clean up performance monitoring
    if (this.perfMonitor) {
      this.perfMonitor.unregister(this.id);
    }
    
    super.destroy();
  }
}

// Add CSS for the component
const style = document.createElement('style');
style.textContent = `
  .task-manager {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    border-radius: 8px;
    background-color: #fff;
  }
  
  .task-manager-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
  }
  
  .task-stats {
    display: flex;
    gap: 12px;
    font-size: 14px;
    color: #666;
  }
  
  .task-form {
    display: flex;
    margin-bottom: 20px;
    gap: 10px;
  }
  
  .task-input {
    flex: 1;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 16px;
  }
  
  .task-add-btn {
    padding: 10px 15px;
    background-color: #4caf50;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
  }
  
  .task-filters, .task-sort {
    display: flex;
    gap: 10px;
    margin-bottom: 15px;
    align-items: center;
  }
  
  .filter-btn, .sort-btn {
    padding: 5px 10px;
    background-color: #f5f5f5;
    border: 1px solid #ddd;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .filter-btn.active, .sort-btn.active {
    background-color: #e0e0e0;
    font-weight: bold;
  }
  
  .task-list {
    list-style: none;
    padding: 0;
  }
  
  .task-item {
    display: flex;
    justify-content: space-between;
    padding: 15px;
    border: 1px solid #eee;
    margin-bottom: 10px;
    border-radius: 4px;
    background-color: #f9f9f9;
  }
  
  .task-item.completed {
    opacity: 0.7;
    background-color: #f0f0f0;
  }
  
  .task-item.completed .task-title {
    text-decoration: line-through;
  }
  
  .task-item-header {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .task-checkbox {
    cursor: pointer;
  }
  
  .task-title {
    font-size: 16px;
  }
  
  .task-item-actions {
    display: flex;
    gap: 10px;
  }
  
  .task-priority {
    padding: 5px;
    border-radius: 4px;
    border: 1px solid #ddd;
  }
  
  .task-delete {
    padding: 5px 10px;
    background-color: #f44336;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .task-empty {
    text-align: center;
    padding: 20px;
    color: #666;
    font-style: italic;
  }
  
  /* Debug Panel Styles */
  .task-debug-panel {
    margin-top: 30px;
    padding: 15px;
    border: 1px dashed #999;
    border-radius: 4px;
    background-color: #f8f8f8;
  }
  
  .debug-section {
    margin-bottom: 15px;
  }
  
  .debug-time-travel {
    width: 100%;
    padding: 5px;
  }
  
  .debug-performance ul {
    padding-left: 20px;
  }
`;

document.head.appendChild(style); 