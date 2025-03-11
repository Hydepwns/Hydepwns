/**
 * Hooks for MonoTabs component.
 * 
 * Provides client-side functionality for the tabbed interface, including
 * keyboard navigation, state persistence, and focus management.
 */

const MonoTabs = {
  mounted() {
    // Set up elements
    this.tabsId = this.el.dataset.tabsId;
    this.tabs = this.el.querySelectorAll('.mono-tabs__tab');
    this.panels = this.el.querySelectorAll('.mono-tabs__panel');
    
    // Set up keyboard navigation
    this.setupKeyboardNavigation();
    
    // Set up persistence if storage is available
    this.setupPersistence();
    
    // Store the current active tab index
    this.activeIndex = this.findActiveTabIndex();
  },
  
  setupKeyboardNavigation() {
    // Add keyboard event listeners to tabs
    this.tabs.forEach(tab => {
      tab.addEventListener('keydown', this.handleTabKeyDown.bind(this));
    });
  },
  
  handleTabKeyDown(event) {
    // Get all tabs as an array for easier navigation
    const tabsArray = Array.from(this.tabs);
    const currentIndex = tabsArray.indexOf(event.target);
    let nextIndex;
    
    switch (event.key) {
      case 'ArrowRight':
      case 'ArrowDown':
        // Move to the next tab
        nextIndex = currentIndex < tabsArray.length - 1 ? currentIndex + 1 : 0;
        tabsArray[nextIndex].click();
        tabsArray[nextIndex].focus();
        event.preventDefault();
        break;
        
      case 'ArrowLeft':
      case 'ArrowUp':
        // Move to the previous tab
        nextIndex = currentIndex > 0 ? currentIndex - 1 : tabsArray.length - 1;
        tabsArray[nextIndex].click();
        tabsArray[nextIndex].focus();
        event.preventDefault();
        break;
        
      case 'Home':
        // Move to the first tab
        tabsArray[0].click();
        tabsArray[0].focus();
        event.preventDefault();
        break;
        
      case 'End':
        // Move to the last tab
        nextIndex = tabsArray.length - 1;
        tabsArray[nextIndex].click();
        tabsArray[nextIndex].focus();
        event.preventDefault();
        break;
    }
  },
  
  setupPersistence() {
    // Check if localStorage is available
    if (typeof localStorage !== 'undefined') {
      // Store the tab ID when it's changed
      this.tabs.forEach(tab => {
        tab.addEventListener('click', () => {
          const tabId = tab.getAttribute('id').replace(`${this.tabsId}-tab-`, '');
          localStorage.setItem(`tab-state-${this.tabsId}`, tabId);
          this.activeIndex = Array.from(this.tabs).indexOf(tab);
        });
      });
      
      // Check if there's a stored tab state and activate that tab
      const storedTabId = localStorage.getItem(`tab-state-${this.tabsId}`);
      if (storedTabId) {
        const tabToActivate = document.getElementById(`${this.tabsId}-tab-${storedTabId}`);
        if (tabToActivate) {
          tabToActivate.click();
        }
      }
    }
  },
  
  findActiveTabIndex() {
    // Find the index of the currently active tab
    const activeTab = this.el.querySelector('.mono-tabs__tab--active');
    return activeTab ? Array.from(this.tabs).indexOf(activeTab) : 0;
  }
};

export { MonoTabs }; 