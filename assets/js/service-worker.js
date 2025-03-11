/**
 * Hydepwns Service Worker
 * 
 * This service worker enables offline capabilities for the Hydepwns application.
 * It caches critical assets and provides offline fallbacks.
 */

// Cache name includes version to facilitate updates
const CACHE_NAME = 'hydepwns-cache-v1';

// Assets to cache on installation
const INITIAL_CACHED_ASSETS = [
  '/',
  '/assets/app.css',
  '/assets/app.js',
  '/assets/images/favicon.ico',
  '/assets/fonts/MonaspaceArgon-Regular.woff2',
  '/assets/fonts/MonaspaceArgon-Bold.woff2',
  '/offline', // Offline fallback page
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
            if (cacheName !== CACHE_NAME) {
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
  
  // For HTML documents (routes), use network-first with cache fallback
  if (destination === 'document') {
    strategy = networkFirstWithCacheFallback(event.request, 'document');
  }
  // For static assets like CSS, JS, fonts, and images, use cache-first
  else if (['style', 'script', 'font', 'image'].includes(destination) ||
           url.pathname.startsWith('/assets/')) {
    strategy = cacheFirstWithNetworkFallback(event.request);
  }
  // For API calls, use network-only
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
      db.createObjectStore('deferred-actions', { keyPath: 'id', autoIncrement: true });
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
  
  // Default fetch for other methods
  return fetch(action.url, {
    method: action.method,
    headers: action.headers
  });
}

// Listen for messages from the client
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
}); 