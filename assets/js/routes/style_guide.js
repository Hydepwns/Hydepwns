/**
 * Style Guide Route Bundle
 * 
 * This file contains all JavaScript that's specific to the style guide route.
 * It's loaded dynamically only when a user visits the style guide page.
 */
import { liveSocket, Hooks } from '../entrypoints/app';
import CopyableCode from "../hooks/copyable_code";
import { initStyleGuide } from "../style_guide";
import { CharacterAnimation, GridFadeIn } from "../components/animations";

// Register route-specific hooks
Hooks.CopyableCode = CopyableCode;
Hooks.CharacterAnimation = CharacterAnimation;
Hooks.GridFadeIn = GridFadeIn;

// Update the LiveSocket with new hooks
liveSocket.updateHooks(Hooks);

// Initialize style guide specific functionality
console.log('Initializing style guide specific functionality');
initStyleGuide();

// Export hooks for potential use in other modules
export { Hooks }; 