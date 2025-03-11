/**
 * Service Worker Registration
 * 
 * This module handles the registration and lifecycle management of the service worker.
 */

// Check if service workers are supported
const isServiceWorkerSupported = 'serviceWorker' in navigator;

/**
 * Register the service worker
 */
export function registerServiceWorker() {
  if (!isServiceWorkerSupported) {
    console.log('Service workers are not supported in this browser.');
    return;
  }
  
  // Register the service worker after the page has loaded
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js', { scope: '/' })
      .then(registration => {
        console.log('Service worker registered successfully:', registration.scope);
        
        // Check for updates to the service worker
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          console.log('New service worker is being installed:', newWorker);
          
          newWorker.addEventListener('statechange', () => {
            console.log('Service worker state changed:', newWorker.state);
            
            // When a new service worker is done installing, show update notification
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              showUpdateNotification(registration);
            }
          });
        });
      })
      .catch(error => {
        console.error('Service worker registration failed:', error);
      });
    
    // Handle service worker messages
    navigator.serviceWorker.addEventListener('message', event => {
      console.log('Message from service worker:', event.data);
      
      // Handle specific messages from the service worker
      if (event.data && event.data.type === 'CACHE_UPDATED') {
        // Handle cache updated message
        console.log('Cache updated with new content');
      }
    });
  });
  
  // Handle controller change (when a new service worker takes over)
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    console.log('Service worker controller changed');
  });
}

/**
 * Update the service worker
 */
export function updateServiceWorker() {
  if (!isServiceWorkerSupported) return;
  
  navigator.serviceWorker.ready
    .then(registration => {
      registration.update();
    })
    .catch(error => {
      console.error('Service worker update failed:', error);
    });
}

/**
 * Check for network status changes and notify service worker
 */
export function initNetworkStatusMonitor() {
  if (!isServiceWorkerSupported) return;
  
  // Handle online status changes
  window.addEventListener('online', () => {
    console.log('App is now online');
    
    // Try to sync deferred updates when back online
    navigator.serviceWorker.ready
      .then(registration => {
        if ('sync' in registration) {
          registration.sync.register('deferred-updates')
            .then(() => {
              console.log('Sync registered for deferred updates');
            })
            .catch(error => {
              console.error('Sync registration failed:', error);
            });
        }
      });
  });
  
  window.addEventListener('offline', () => {
    console.log('App is now offline');
  });
}

/**
 * Show a notification that an update is available
 */
function showUpdateNotification(registration) {
  // Create a notification element
  const notification = document.createElement('div');
  notification.className = 'update-notification';
  notification.style.position = 'fixed';
  notification.style.bottom = '20px';
  notification.style.right = '20px';
  notification.style.padding = '15px 20px';
  notification.style.background = 'var(--background-color-alt)';
  notification.style.border = '2px solid var(--text-color)';
  notification.style.color = 'var(--text-color)';
  notification.style.fontFamily = 'var(--font-family)';
  notification.style.zIndex = '9999';
  notification.style.maxWidth = '300px';
  notification.style.transition = 'transform 0.3s, opacity 0.3s';
  
  // Add notification content
  notification.innerHTML = `
    <p>A new version is available</p>
    <div style="display: flex; justify-content: space-between; margin-top: 10px;">
      <button id="update-now" style="margin-right: 10px;">Update Now</button>
      <button id="update-later">Later</button>
    </div>
  `;
  
  // Add notification to the page
  document.body.appendChild(notification);
  
  // Handle update now button
  document.getElementById('update-now').addEventListener('click', () => {
    // Send message to the service worker to skip waiting
    registration.waiting.postMessage({ type: 'SKIP_WAITING' });
    
    // Close the notification
    notification.style.transform = 'translateY(20px)';
    notification.style.opacity = '0';
    
    setTimeout(() => {
      if (document.body.contains(notification)) {
        document.body.removeChild(notification);
      }
    }, 300);
  });
  
  // Handle update later button
  document.getElementById('update-later').addEventListener('click', () => {
    // Close the notification
    notification.style.transform = 'translateY(20px)';
    notification.style.opacity = '0';
    
    setTimeout(() => {
      if (document.body.contains(notification)) {
        document.body.removeChild(notification);
      }
    }, 300);
  });
}

/**
 * Save data for offline use
 */
export function saveForOffline(action) {
  if (!isServiceWorkerSupported) return Promise.reject(new Error('Service workers not supported'));
  
  return new Promise((resolve, reject) => {
    // Open the database
    const request = indexedDB.open('hydepwns-offline', 1);
    
    request.onerror = () => reject(new Error('Failed to open database'));
    
    request.onsuccess = () => {
      const db = request.result;
      const transaction = db.transaction(['deferred-actions'], 'readwrite');
      const store = transaction.objectStore('deferred-actions');
      
      // Add the action to the deferred actions store
      const addRequest = store.add(action);
      
      addRequest.onerror = () => reject(new Error('Failed to save action'));
      addRequest.onsuccess = () => {
        resolve();
        
        // Try to schedule a sync if we're online
        if (navigator.onLine) {
          navigator.serviceWorker.ready
            .then(registration => {
              if ('sync' in registration) {
                registration.sync.register('deferred-updates')
                  .catch(error => {
                    console.error('Sync registration failed:', error);
                  });
              }
            });
        }
      };
    };
    
    request.onupgradeneeded = (event) => {
      const db = event.target.result;
      if (!db.objectStoreNames.contains('deferred-actions')) {
        db.createObjectStore('deferred-actions', { keyPath: 'id', autoIncrement: true });
      }
    };
  });
}

// Initialize the service worker and network monitoring
export function initServiceWorker() {
  registerServiceWorker();
  initNetworkStatusMonitor();
  
  // Check for updates periodically
  setInterval(() => {
    if (navigator.onLine) {
      updateServiceWorker();
    }
  }, 60 * 60 * 1000); // Check every hour
} 