/**
 * FileDrop Component
 * ----------------
 * Provides drag and drop file upload functionality with visual feedback
 * and file validation. Supports single or multiple file uploads, file type
 * restrictions, and size limits.
 * 
 * Built using the robust component system.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class FileDropComponent {
  /**
   * Create a new FileDrop component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `file-drop-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (required)
      accept: '*/*', // Accepted file types (e.g., 'image/*', '.pdf,.docx', etc.)
      multiple: false, // Whether to allow multiple file selection
      maxSize: 10 * 1024 * 1024, // Default max file size (10MB)
      maxFiles: 5, // Maximum number of files when multiple is true
      dropZoneText: 'Drop files here or click to upload', // Text shown in the drop zone
      dropZoneActiveText: 'Release to upload', // Text shown when dragging over
      fileDroppedCallback: null, // Callback when files are dropped
      fileRejectedCallback: null, // Callback when files are rejected
      showFileList: true, // Whether to show list of selected files
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isDragOver: false,
      files: [], // Array of accepted files
      rejectedFiles: [], // Array of rejected files with reasons
      isUploading: false // Whether files are currently being uploaded
    };
    
    // DOM element references
    this.elements = {
      container: null,
      dropZone: null,
      fileInput: null,
      fileList: null,
      uploadButton: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[FileDrop:${this.componentId}]`, ...args);
        }
      }
    };
  }
  
  /**
   * Initialize the component and mount it to the DOM
   * @returns {this} - For method chaining
   */
  mount() {
    // Get event manager for this component
    this.events = EventManager.registerComponent(this.componentId);
    
    // Get cleanup registry for this component
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Store container reference
    this.elements.container = this.options.container || this.options.liveViewHook?.el;
    
    if (!this.elements.container) {
      console.error('FileDrop component requires a container element');
      return this;
    }
    
    // Build the DOM structure
    this._buildDOM();
    
    // Set up event listeners
    this._setupEventListeners();
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Programmatically add files to the drop zone
   * @param {FileList|File[]} files - Files to add
   * @returns {this} - For method chaining
   */
  addFiles(files) {
    this._handleFiles(files);
    return this;
  }
  
  /**
   * Remove a file from the selection
   * @param {number} index - Index of the file to remove
   * @returns {this} - For method chaining
   */
  removeFile(index) {
    if (index >= 0 && index < this._state.files.length) {
      const updatedFiles = [...this._state.files];
      updatedFiles.splice(index, 1);
      this._setState({ files: updatedFiles });
    }
    return this;
  }
  
  /**
   * Clear all selected files
   * @returns {this} - For method chaining
   */
  clearFiles() {
    this._setState({ 
      files: [],
      rejectedFiles: []
    });
    return this;
  }
  
  /**
   * Get currently selected files
   * @returns {File[]} - Array of selected files
   */
  getFiles() {
    return [...this._state.files];
  }
  
  /**
   * Programmatically trigger file selection dialog
   * @returns {this} - For method chaining
   */
  browseFiles() {
    if (this.elements.fileInput) {
      this.elements.fileInput.click();
    }
    return this;
  }
  
  /**
   * Build the DOM structure for the component
   * @private
   */
  _buildDOM() {
    // Create drop zone container
    this.elements.dropZone = DOMCleanup.createElement('div', {
      className: 'file-drop__zone',
      id: `${this.componentId}-zone`,
      'data-component': 'file-drop-zone'
    }, '', this.cleanup);
    
    // Create hidden file input
    this.elements.fileInput = DOMCleanup.createElement('input', {
      type: 'file',
      className: 'file-drop__input',
      accept: this.options.accept,
      multiple: this.options.multiple,
      style: 'display: none;'
    }, '', this.cleanup);
    
    // Create dropzone content
    const dropZoneContent = DOMCleanup.createElement('div', {
      className: 'file-drop__content'
    }, '', this.cleanup);
    
    // Create dropzone icon
    const uploadIcon = DOMCleanup.createElement('div', {
      className: 'file-drop__icon'
    }, '', this.cleanup);
    
    // Create instructions text
    const instructions = DOMCleanup.createElement('p', {
      className: 'file-drop__text'
    }, this.options.dropZoneText, this.cleanup);
    
    // Create file type hint
    const fileTypeHint = DOMCleanup.createElement('p', {
      className: 'file-drop__hint'
    }, `Accepted files: ${this.options.accept}`, this.cleanup);
    
    // Create file list container if needed
    if (this.options.showFileList) {
      this.elements.fileList = DOMCleanup.createElement('div', {
        className: 'file-drop__file-list',
        style: 'display: none;'
      }, '', this.cleanup);
    }
    
    // Assemble the component
    dropZoneContent.appendChild(uploadIcon);
    dropZoneContent.appendChild(instructions);
    dropZoneContent.appendChild(fileTypeHint);
    
    this.elements.dropZone.appendChild(dropZoneContent);
    this.elements.dropZone.appendChild(this.elements.fileInput);
    
    this.elements.container.appendChild(this.elements.dropZone);
    
    if (this.elements.fileList) {
      this.elements.container.appendChild(this.elements.fileList);
    }
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    // Drag events for the drop zone
    this.events.addEventListener(
      this.elements.dropZone,
      'dragenter',
      this._handleDragEnter.bind(this)
    );
    
    this.events.addEventListener(
      this.elements.dropZone,
      'dragover',
      this._handleDragOver.bind(this)
    );
    
    this.events.addEventListener(
      this.elements.dropZone,
      'dragleave',
      this._handleDragLeave.bind(this)
    );
    
    this.events.addEventListener(
      this.elements.dropZone,
      'drop',
      this._handleDrop.bind(this)
    );
    
    // Click to browse files
    this.events.addEventListener(
      this.elements.dropZone,
      'click',
      this._handleZoneClick.bind(this)
    );
    
    // File input change event
    this.events.addEventListener(
      this.elements.fileInput,
      'change',
      this._handleFileInputChange.bind(this)
    );
  }
  
  /**
   * Handle dragenter event
   * @param {DragEvent} event - Drag event
   * @private
   */
  _handleDragEnter(event) {
    event.preventDefault();
    event.stopPropagation();
    this._setState({ isDragOver: true });
  }
  
  /**
   * Handle dragover event
   * @param {DragEvent} event - Drag event
   * @private
   */
  _handleDragOver(event) {
    event.preventDefault();
    event.stopPropagation();
    if (!this._state.isDragOver) {
      this._setState({ isDragOver: true });
    }
  }
  
  /**
   * Handle dragleave event
   * @param {DragEvent} event - Drag event
   * @private
   */
  _handleDragLeave(event) {
    event.preventDefault();
    event.stopPropagation();
    
    // Only set isDragOver to false if we're leaving the drop zone (not a child element)
    const rect = this.elements.dropZone.getBoundingClientRect();
    const x = event.clientX;
    const y = event.clientY;
    
    if (
      x <= rect.left ||
      x >= rect.right ||
      y <= rect.top ||
      y >= rect.bottom
    ) {
      this._setState({ isDragOver: false });
    }
  }
  
  /**
   * Handle drop event
   * @param {DragEvent} event - Drag event
   * @private
   */
  _handleDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    
    this._setState({ isDragOver: false });
    
    if (event.dataTransfer.files) {
      this._handleFiles(event.dataTransfer.files);
    }
  }
  
  /**
   * Handle click on drop zone
   * @private
   */
  _handleZoneClick() {
    this.browseFiles();
  }
  
  /**
   * Handle file input change event
   * @param {Event} event - Change event
   * @private
   */
  _handleFileInputChange(event) {
    if (event.target.files) {
      this._handleFiles(event.target.files);
    }
  }
  
  /**
   * Process files, validate them, and update state
   * @param {FileList|File[]} fileList - Files to process
   * @private
   */
  _handleFiles(fileList) {
    const files = Array.from(fileList);
    const acceptedFiles = [];
    const rejectedFiles = [];
    
    // Process each file
    files.forEach(file => {
      const validationResult = this._validateFile(file);
      
      if (validationResult.valid) {
        acceptedFiles.push(file);
      } else {
        rejectedFiles.push({
          file,
          reason: validationResult.reason
        });
      }
    });
    
    // Check if we exceed max files
    if (this.options.multiple && this._state.files.length + acceptedFiles.length > this.options.maxFiles) {
      const extraFiles = acceptedFiles.splice(this.options.maxFiles - this._state.files.length);
      
      extraFiles.forEach(file => {
        rejectedFiles.push({
          file,
          reason: `Maximum number of files (${this.options.maxFiles}) exceeded`
        });
      });
    }
    
    // Update state with new files
    this._setState({
      files: this.options.multiple 
        ? [...this._state.files, ...acceptedFiles]
        : acceptedFiles.length > 0 ? [acceptedFiles[0]] : [],
      rejectedFiles: [...this._state.rejectedFiles, ...rejectedFiles]
    });
    
    // Call callbacks
    if (acceptedFiles.length > 0 && typeof this.options.fileDroppedCallback === 'function') {
      this.options.fileDroppedCallback(acceptedFiles);
    }
    
    if (rejectedFiles.length > 0 && typeof this.options.fileRejectedCallback === 'function') {
      this.options.fileRejectedCallback(rejectedFiles);
    }
    
    // Trigger LiveView event if hook provided
    if (this.options.liveViewHook && acceptedFiles.length > 0) {
      this.options.liveViewHook.pushEvent('files_selected', { 
        files: acceptedFiles.map(file => ({
          name: file.name,
          size: file.size,
          type: file.type
        }))
      });
    }
    
    // Render file list
    this._renderFileList();
  }
  
  /**
   * Validate a file against accepted types and size limits
   * @param {File} file - File to validate
   * @returns {Object} - Validation result { valid: boolean, reason: string }
   * @private
   */
  _validateFile(file) {
    // Validate file type
    if (this.options.accept !== '*/*') {
      const accept = this.options.accept.split(',');
      const fileType = file.type;
      const fileName = file.name;
      const fileExtension = `.${fileName.split('.').pop().toLowerCase()}`;
      
      let isValidType = false;
      
      for (const type of accept) {
        const trimmedType = type.trim();
        
        if (
          trimmedType === '*/*' ||
          (trimmedType.endsWith('/*') && fileType.startsWith(trimmedType.slice(0, -1))) ||
          (trimmedType.startsWith('.') && fileExtension === trimmedType.toLowerCase()) ||
          fileType === trimmedType
        ) {
          isValidType = true;
          break;
        }
      }
      
      if (!isValidType) {
        return {
          valid: false,
          reason: `File type not accepted. Allowed types: ${this.options.accept}`
        };
      }
    }
    
    // Validate file size
    if (file.size > this.options.maxSize) {
      const maxSizeMB = (this.options.maxSize / (1024 * 1024)).toFixed(2);
      return {
        valid: false,
        reason: `File size exceeds maximum allowed size (${maxSizeMB} MB)`
      };
    }
    
    return { valid: true };
  }
  
  /**
   * Render the list of selected files
   * @private
   */
  _renderFileList() {
    if (!this.elements.fileList || !this.options.showFileList) return;
    
    // Clear current list
    this.elements.fileList.innerHTML = '';
    
    const files = this._state.files;
    
    if (files.length === 0) {
      this.elements.fileList.style.display = 'none';
      return;
    }
    
    this.elements.fileList.style.display = 'block';
    
    // Create file list items
    files.forEach((file, index) => {
      const fileItem = DOMCleanup.createElement('div', {
        className: 'file-drop__file-item'
      }, '', this.cleanup);
      
      // File info
      const fileInfo = DOMCleanup.createElement('div', {
        className: 'file-drop__file-info'
      }, '', this.cleanup);
      
      // File name
      const fileName = DOMCleanup.createElement('div', {
        className: 'file-drop__file-name'
      }, file.name, this.cleanup);
      
      // File size
      const fileSize = DOMCleanup.createElement('div', {
        className: 'file-drop__file-size'
      }, this._formatFileSize(file.size), this.cleanup);
      
      // Remove button
      const removeButton = DOMCleanup.createElement('button', {
        className: 'file-drop__remove-btn',
        type: 'button',
        'aria-label': `Remove file ${file.name}`
      }, '×', this.cleanup);
      
      // Add event listener for remove button
      this.events.addEventListener(
        removeButton,
        'click',
        () => this.removeFile(index)
      );
      
      // Assemble file item
      fileInfo.appendChild(fileName);
      fileInfo.appendChild(fileSize);
      
      fileItem.appendChild(fileInfo);
      fileItem.appendChild(removeButton);
      
      this.elements.fileList.appendChild(fileItem);
    });
    
    // Add rejected files if any
    this._state.rejectedFiles.forEach(({ file, reason }) => {
      const fileItem = DOMCleanup.createElement('div', {
        className: 'file-drop__file-item file-drop__file-item--rejected'
      }, '', this.cleanup);
      
      const fileInfo = DOMCleanup.createElement('div', {
        className: 'file-drop__file-info'
      }, '', this.cleanup);
      
      const fileName = DOMCleanup.createElement('div', {
        className: 'file-drop__file-name'
      }, file.name, this.cleanup);
      
      const errorReason = DOMCleanup.createElement('div', {
        className: 'file-drop__file-error'
      }, reason, this.cleanup);
      
      fileInfo.appendChild(fileName);
      fileInfo.appendChild(errorReason);
      
      fileItem.appendChild(fileInfo);
      
      this.elements.fileList.appendChild(fileItem);
    });
  }
  
  /**
   * Format file size in a human-readable format
   * @param {number} bytes - File size in bytes
   * @returns {string} - Formatted file size
   * @private
   */
  _formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
  
  /**
   * Update component state and trigger re-render
   * @param {Object} newState - New state properties
   * @private
   */
  _setState(newState) {
    this._state = { ...this._state, ...newState };
    
    // Update UI based on new state
    this._updateUI();
  }
  
  /**
   * Update UI based on current state
   * @private
   */
  _updateUI() {
    // Update drop zone appearance based on dragover state
    if (this._state.isDragOver) {
      this.elements.dropZone.classList.add('file-drop__zone--active');
      
      // Update text if dropZoneActiveText is provided
      const textEl = this.elements.dropZone.querySelector('.file-drop__text');
      if (textEl) {
        textEl.textContent = this.options.dropZoneActiveText;
      }
    } else {
      this.elements.dropZone.classList.remove('file-drop__zone--active');
      
      // Restore original text
      const textEl = this.elements.dropZone.querySelector('.file-drop__text');
      if (textEl) {
        textEl.textContent = this.options.dropZoneText;
      }
    }
    
    // Handle file list display
    if (this.options.showFileList) {
      this._renderFileList();
    }
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const FileDrop = {
  mounted() {
    this.component = new FileDropComponent({
      liveViewHook: this,
      container: this.el,
      accept: this.el.dataset.accept || '*/*',
      multiple: this.el.dataset.multiple === 'true',
      maxSize: parseInt(this.el.dataset.maxSize, 10) || 10 * 1024 * 1024,
      maxFiles: parseInt(this.el.dataset.maxFiles, 10) || 5,
      dropZoneText: this.el.dataset.dropZoneText || 'Drop files here or click to upload',
      dropZoneActiveText: this.el.dataset.dropZoneActiveText || 'Release to upload',
      showFileList: this.el.dataset.showFileList !== 'false',
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    // Nothing to update specifically
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default FileDrop;
export { FileDropComponent }; 