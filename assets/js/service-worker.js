/**
 * Hydepwns Service Worker
 * 
 * This service worker enables offline capabilities for the Hydepwns application.
 * It caches critical assets and provides offline fallbacks.
 */

// Cache name includes version to facilitate updates
const CACHE_NAME = 'hydepwns-cache-v2';
const TERMINAL_CACHE_NAME = 'hydepwns-terminal-cache-v1';

// Assets to cache on installation
const INITIAL_CACHED_ASSETS = [
  '/',
  '/assets/app.css',
  '/assets/app.js',
  '/assets/images/favicon.ico',
  '/assets/fonts/MonaspaceArgon-Regular.woff2',
  '/assets/fonts/MonaspaceArgon-Bold.woff2',
  '/offline', // Offline fallback page
  
  // Terminal-specific assets for offline functionality
  '/assets/js/terminal-offline.js',
  '/assets/css/components/terminal.css',
  '/assets/css/responsive/terminal.scss',
  '/assets/css/performance/mobile_optimizations.scss',
  
  // Documentation resources for offline access
  '/docs/terminal',
  '/docs/style-guide',
  '/docs/basic-commands'
];

// Additional assets that can be cached later as encountered
const OPTIONAL_CACHED_ASSETS = [
  '/assets/fonts/MonaspaceArgon-ExtraBold.woff2',
  '/assets/fonts/MonaspaceArgon-Italic.woff2',
  '/assets/fonts/MonaspaceArgon-BoldItalic.woff2',
  '/assets/fonts/MonaspaceArgon-ExtraBoldItalic.woff2',
];

// Install event - cache initial assets
self.addEventListener('install', (event) => {
  // Skip waiting to activate the service worker immediately
  self.skipWaiting();
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Caching initial assets');
        return cache.addAll(INITIAL_CACHED_ASSETS);
      })
      .catch((error) => {
        console.error('[Service Worker] Initial caching failed:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  // Claim clients to take control immediately
  event.waitUntil(self.clients.claim());
  
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME && cacheName !== TERMINAL_CACHE_NAME) {
              console.log('[Service Worker] Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
  );
});

// Network first with cache fallback strategy for HTML documents
const networkFirstWithCacheFallback = async (request, destinationName) => {
  try {
    console.log(`[Service Worker] Fetching ${destinationName}:`, request.url);
    // Try network first
    const networkResponse = await fetch(request);
    
    // If successful, clone and cache the response
    if (networkResponse.ok) {
      const responseToCache = networkResponse.clone();
      const cache = await caches.open(CACHE_NAME);
      await cache.put(request, responseToCache);
      console.log(`[Service Worker] Network response cached for ${request.url}`);
    }
    
    return networkResponse;
  } catch (error) {
    console.log(`[Service Worker] Network failed for ${request.url}, using cache`);
    // If network fails, try cache
    const cachedResponse = await caches.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // If not in cache and this is a document, return offline page
    if (destinationName === 'document') {
      console.log('[Service Worker] No cached response, using offline page');
      return caches.match('/offline');
    }
    
    throw error;
  }
};

// Cache first with network fallback strategy for static assets
const cacheFirstWithNetworkFallback = async (request) => {
  // Try cache first
  const cachedResponse = await caches.match(request);
  
  if (cachedResponse) {
    return cachedResponse;
  }
  
  // If not in cache, try network
  try {
    const networkResponse = await fetch(request);
    
    // If successful, clone and cache the response
    if (networkResponse.ok) {
      const responseToCache = networkResponse.clone();
      const cache = await caches.open(CACHE_NAME);
      await cache.put(request, responseToCache);
      console.log(`[Service Worker] Network response cached for ${request.url}`);
    }
    
    return networkResponse;
  } catch (error) {
    console.error(`[Service Worker] Failed to fetch ${request.url}:`, error);
    throw error;
  }
};

// Special terminal API handling (modified for offline support)
const terminalApiHandler = async (request) => {
  try {
    // Try network first for terminal requests
    const networkResponse = await fetch(request);
    
    // If successful, clone and cache the response
    if (networkResponse.ok) {
      const responseToCache = networkResponse.clone();
      const cache = await caches.open(TERMINAL_CACHE_NAME);
      await cache.put(request, responseToCache);
      console.log(`[Service Worker] Terminal API response cached: ${request.url}`);
    }
    
    return networkResponse;
  } catch (error) {
    console.log(`[Service Worker] Terminal API network request failed, using cache`);
    
    // If network fails, try cache
    const cachedResponse = await caches.match(request, { cacheName: TERMINAL_CACHE_NAME });
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // If the terminal API request is not in cache, generate a fallback response
    if (request.url.includes('/api/terminal')) {
      return generateOfflineTerminalResponse(request);
    }
    
    // For other API requests, return a generic error
    return new Response(
      JSON.stringify({ 
        error: 'You are currently offline. This action will be synced when you reconnect.',
        offline: true
      }),
      { 
        status: 200, 
        headers: { 'Content-Type': 'application/json' } 
      }
    );
  }
};

// Network only strategy for API and live features
const networkOnly = async (request) => {
  return fetch(request);
};

// Fetch event - intercept requests and serve from cache when appropriate
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  const destination = event.request.destination;
  
  // Skip requests to the Phoenix LiveView WebSocket and /live path
  if (url.pathname.startsWith('/live') || url.pathname.startsWith('/phoenix')) {
    return;
  }
  
  // Skip cross-origin requests
  if (url.origin !== self.location.origin) {
    return;
  }
  
  // Strategy selection based on request type
  let strategy;
  
  // Special handling for terminal API requests
  if (url.pathname.startsWith('/api/terminal')) {
    strategy = terminalApiHandler(event.request);
  }
  // For HTML documents (routes), use network-first with cache fallback
  else if (destination === 'document') {
    strategy = networkFirstWithCacheFallback(event.request, 'document');
  }
  // For static assets like CSS, JS, fonts, and images, use cache-first
  else if (['style', 'script', 'font', 'image'].includes(destination) ||
           url.pathname.startsWith('/assets/')) {
    strategy = cacheFirstWithNetworkFallback(event.request);
  }
  // For other API calls, use network-only (with exception for terminal API)
  else if (url.pathname.startsWith('/api/')) {
    strategy = networkOnly(event.request);
  }
  // Default to network-first for everything else
  else {
    strategy = networkFirstWithCacheFallback(event.request, 'other');
  }
  
  event.respondWith(strategy);
});

// Background sync for deferred actions
self.addEventListener('sync', (event) => {
  if (event.tag === 'deferred-updates') {
    event.waitUntil(handleDeferredUpdates());
  } else if (event.tag === 'terminal-sync') {
    event.waitUntil(syncTerminalData());
  }
});

// Handle messages from the client
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'CACHE_TERMINAL_COMMAND') {
    cacheTerminalCommand(event.data.payload);
  } else if (event.data && event.data.type === 'CACHE_TERMINAL_PREFERENCES') {
    cacheTerminalPreferences(event.data.payload);
  } else if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

// Handle deferred updates when online
async function handleDeferredUpdates() {
  try {
    // Get deferred actions from IndexedDB
    const db = await openDatabase();
    const deferredActions = await getAllDeferredActions(db);
    
    // Process each action
    for (const action of deferredActions) {
      try {
        await processAction(action);
        await removeAction(db, action.id);
      } catch (error) {
        console.error('[Service Worker] Failed to process action:', error);
      }
    }
  } catch (error) {
    console.error('[Service Worker] Deferred updates failed:', error);
  }
}

// Simple database functions (would be expanded in a real implementation)
async function openDatabase() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open('hydepwns-offline', 1);
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    
    request.onupgradeneeded = (event) => {
      const db = event.target.result;
      if (!db.objectStoreNames.contains('deferred-actions')) {
        db.createObjectStore('deferred-actions', { keyPath: 'id', autoIncrement: true });
      }
      if (!db.objectStoreNames.contains('terminal-commands')) {
        db.createObjectStore('terminal-commands', { keyPath: 'id', autoIncrement: true });
      }
      if (!db.objectStoreNames.contains('terminal-preferences')) {
        db.createObjectStore('terminal-preferences', { keyPath: 'id' });
      }
    };
  });
}

async function getAllDeferredActions(db) {
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(['deferred-actions'], 'readonly');
    const store = transaction.objectStore('deferred-actions');
    const request = store.getAll();
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
  });
}

async function removeAction(db, id) {
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(['deferred-actions'], 'readwrite');
    const store = transaction.objectStore('deferred-actions');
    const request = store.delete(id);
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve();
  });
}

async function processAction(action) {
  // Implement the logic to send stored actions to the server
  console.log('[Service Worker] Processing deferred action:', action);
  
  // Example implementation for a POST request
  if (action.method === 'POST') {
    return fetch(action.url, {
      method: 'POST',
      headers: action.headers,
      body: action.body
    });
  }
  
  // Implement other methods as needed
  // ...
  
  return Promise.resolve();
}

// Terminal-specific functions for offline support

/**
 * Store terminal command in IndexedDB for offline access
 */
async function cacheTerminalCommand(command) {
  try {
    const db = await openDatabase();
    const transaction = db.transaction(['terminal-commands'], 'readwrite');
    const store = transaction.objectStore('terminal-commands');
    
    // Add timestamp to command
    const commandToStore = {
      ...command,
      timestamp: Date.now()
    };
    
    await store.add(commandToStore);
    console.log('[Service Worker] Terminal command cached:', commandToStore);
  } catch (error) {
    console.error('[Service Worker] Failed to cache terminal command:', error);
  }
}

/**
 * Store terminal preferences in IndexedDB for offline access
 */
async function cacheTerminalPreferences(preferences) {
  try {
    const db = await openDatabase();
    const transaction = db.transaction(['terminal-preferences'], 'readwrite');
    const store = transaction.objectStore('terminal-preferences');
    
    // Use terminal ID as the key
    const terminalId = preferences.id || 'default';
    
    // Add or update preferences
    await store.put({
      id: terminalId,
      preferences: preferences,
      timestamp: Date.now()
    });
    
    console.log('[Service Worker] Terminal preferences cached for:', terminalId);
  } catch (error) {
    console.error('[Service Worker] Failed to cache terminal preferences:', error);
  }
}

/**
 * Sync terminal data when back online
 */
async function syncTerminalData() {
  try {
    const db = await openDatabase();
    
    // Get all cached commands that need to be synced
    const commands = await new Promise((resolve, reject) => {
      const transaction = db.transaction(['terminal-commands'], 'readonly');
      const store = transaction.objectStore('terminal-commands');
      const request = store.getAll();
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve(request.result);
    });
    
    // Send cached commands to server
    if (commands.length > 0) {
      console.log('[Service Worker] Syncing terminal commands:', commands);
      
      // Send each command to server
      for (const command of commands) {
        try {
          await fetch('/api/terminal/sync', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(command)
          });
          
          // Remove synced command
          const transaction = db.transaction(['terminal-commands'], 'readwrite');
          const store = transaction.objectStore('terminal-commands');
          await store.delete(command.id);
        } catch (error) {
          console.error('[Service Worker] Failed to sync terminal command:', error);
        }
      }
    }
    
    // Sync preferences as well
    await syncTerminalPreferences(db);
    
  } catch (error) {
    console.error('[Service Worker] Terminal data sync failed:', error);
  }
}

/**
 * Sync terminal preferences when back online
 */
async function syncTerminalPreferences(db) {
  try {
    // Get all cached preferences that need to be synced
    const preferences = await new Promise((resolve, reject) => {
      const transaction = db.transaction(['terminal-preferences'], 'readonly');
      const store = transaction.objectStore('terminal-preferences');
      const request = store.getAll();
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve(request.result);
    });
    
    // Send cached preferences to server
    if (preferences.length > 0) {
      console.log('[Service Worker] Syncing terminal preferences:', preferences);
      
      // Send each preference set to server
      for (const pref of preferences) {
        try {
          await fetch('/api/terminal/preferences/sync', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(pref.preferences)
          });
          
          // Keep preferences in IndexedDB for offline use, but mark as synced
          const transaction = db.transaction(['terminal-preferences'], 'readwrite');
          const store = transaction.objectStore('terminal-preferences');
          await store.put({
            ...pref,
            synced: true
          });
        } catch (error) {
          console.error('[Service Worker] Failed to sync terminal preferences:', error);
        }
      }
    }
  } catch (error) {
    console.error('[Service Worker] Terminal preferences sync failed:', error);
  }
}

/**
 * Generate offline response for terminal API requests
 */
async function generateOfflineTerminalResponse(request) {
  try {
    // Parse request to determine what kind of terminal request it is
    const url = new URL(request.url);
    
    // Handle different terminal API endpoints
    if (url.pathname === '/api/terminal/command') {
      // Return generic offline command response
      return new Response(
        JSON.stringify({
          result: {
            output: [
              {
                type: 'system',
                content: 'You are currently offline. Your command has been saved and will be processed when you reconnect.'
              }
            ],
            status: 'offline'
          },
          offline: true
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }
    
    if (url.pathname === '/api/terminal/history') {
      // Return cached command history
      const db = await openDatabase();
      const commands = await new Promise((resolve, reject) => {
        const transaction = db.transaction(['terminal-commands'], 'readonly');
        const store = transaction.objectStore('terminal-commands');
        const request = store.getAll();
        
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve(request.result);
      });
      
      return new Response(
        JSON.stringify({
          history: commands.map(cmd => cmd.command),
          offline: true
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }
    
    if (url.pathname === '/api/terminal/preferences') {
      // Return cached preferences
      const terminalId = url.searchParams.get('id') || 'default';
      const db = await openDatabase();
      
      const preferences = await new Promise((resolve, reject) => {
        const transaction = db.transaction(['terminal-preferences'], 'readonly');
        const store = transaction.objectStore('terminal-preferences');
        const request = store.get(terminalId);
        
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve(request.result?.preferences || {});
      });
      
      return new Response(
        JSON.stringify({
          preferences: preferences,
          offline: true
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }
    
    // Default offline terminal response
    return new Response(
      JSON.stringify({
        message: 'Terminal is in offline mode. Limited functionality is available.',
        offline: true
      }),
      { 
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      }
    );
  } catch (error) {
    console.error('[Service Worker] Failed to generate offline terminal response:', error);
    
    // Return a generic error response
    return new Response(
      JSON.stringify({ 
        error: 'Terminal offline processing failed',
        offline: true
      }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    );
  }
} 