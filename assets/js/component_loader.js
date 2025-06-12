const componentRegistry = {
  // Selector to find on page: function to dynamically import the component
  "[data-action='toggle-accessibility-menu']": () => import('./components/accessibility_menu_toggle.js'),
  "[data-action='copy-code']": () => import('./components/copyable_code.js'),
  "[data-action='toggle-info-box']": () => import('./components/info_box.js'),
  // These are general and should be loaded on any page with a body
  'body': [ 
    () => import('./components/keyboard_navigation.js'),
    () => import('./utils/viewport_detector.js'),
  ],
  '[data-tab]': () => import('./components/mono_tabs.js'),
  "[data-action='dismiss-notification']": () => import('./components/notifications.js'),
  "[data-action='dismiss-toast']": () => import('./components/toast.js'),
};

const loadedComponents = new Set();

function loadComponents() {
  Object.entries(componentRegistry).forEach(([selector, loaders]) => {
    if (document.querySelector(selector)) {
      const loaderArray = Array.isArray(loaders) ? loaders : [loaders];
      loaderArray.forEach(loader => {
        const loaderKey = loader.toString();
        if (!loadedComponents.has(loaderKey)) {
          loader();
          loadedComponents.add(loaderKey);
        }
      });
    }
  });
}

document.addEventListener('DOMContentLoaded', loadComponents);

window.addEventListener('phx:page-loading-stop', loadComponents); 