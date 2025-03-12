/**
 * Battery Optimizations Module
 * 
 * Provides functions to detect battery status and optimize performance
 * on low battery situations for mobile devices.
 */

/**
 * Gets detailed battery information using the Battery Status API
 * 
 * @returns {Promise<BatteryManager|null>} Battery information or null if not supported
 */
export async function getBatteryInfo() {
  // Check if the Battery API is available
  if ('getBattery' in navigator) {
    try {
      const battery = await navigator.getBattery();
      return battery;
    } catch (error) {
      console.warn('Battery API error:', error);
      return null;
    }
  } else if ('battery' in navigator) {
    // Fallback for older implementations
    return navigator.battery;
  }
  
  console.warn('Battery API not supported');
  return null;
}

/**
 * Checks if the device's battery is low
 * Low is defined as below 15% and not charging
 * 
 * @returns {Promise<boolean>} True if battery is low, false otherwise
 */
export async function isBatteryLow() {
  const battery = await getBatteryInfo();
  
  if (!battery) {
    // If we can't detect battery, assume it's not low
    return false;
  }
  
  // Consider battery low if it's below 15% and not charging
  return battery.level <= 0.15 && !battery.charging;
}

/**
 * Applies optimizations for low battery scenarios
 * 
 * @param {HTMLElement} root - The root element to apply optimizations to (usually document.documentElement)
 */
export function applyLowBatteryOptimizations(root = document.documentElement) {
  // Add CSS class for low battery optimizations
  root.classList.add('low-battery-mode');
  
  // Reduce animation durations
  root.style.setProperty('--animation-duration-factor', '1.5');
  
  // Reduce transition durations
  root.style.setProperty('--transition-duration-factor', '1.5');
  
  // Disable non-essential animations
  document.querySelectorAll('.non-essential-animation').forEach(element => {
    element.classList.add('animation-disabled');
  });
  
  console.log('Applied low battery optimizations');
}

/**
 * Removes low battery optimizations
 * 
 * @param {HTMLElement} root - The root element to remove optimizations from (usually document.documentElement)
 */
export function removeLowBatteryOptimizations(root = document.documentElement) {
  // Remove CSS class for low battery optimizations
  root.classList.remove('low-battery-mode');
  
  // Reset animation durations
  root.style.removeProperty('--animation-duration-factor');
  
  // Reset transition durations
  root.style.removeProperty('--transition-duration-factor');
  
  // Re-enable animations
  document.querySelectorAll('.animation-disabled').forEach(element => {
    element.classList.remove('animation-disabled');
  });
  
  console.log('Removed low battery optimizations');
} 