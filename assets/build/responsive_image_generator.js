const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const glob = require('glob');

// Source and destination directories
const STATIC_DIR = path.join(__dirname, '../../priv/static');
const IMAGES_DIR = path.join(STATIC_DIR, 'images');
const RESPONSIVE_DIR = path.join(IMAGES_DIR, 'responsive');

// Make sure responsive directory exists
if (!fs.existsSync(RESPONSIVE_DIR)) {
  fs.mkdirSync(RESPONSIVE_DIR, { recursive: true });
}

// Configuration for responsive images
const IMAGE_SIZES = [320, 640, 960, 1280, 1920]; // Width in pixels
const IMAGE_QUALITIES = [
  { name: 'low', quality: 60 }, // Lower quality for slow connections
  { name: 'medium', quality: 75 }, // Medium quality for average connections
  { name: 'high', quality: 90 } // High quality for fast connections
];

/**
 * Check if cwebp is installed
 */
function checkCwebpInstalled() {
  try {
    execSync('which cwebp', { stdio: 'ignore' });
    return true;
  } catch (error) {
    console.error('Error: cwebp is not installed. Please install it using:');
    console.error('  brew install webp');
    console.error('or visit https://developers.google.com/speed/webp/download');
    return false;
  }
}

/**
 * Generates responsive variants of an image
 * @param {string} inputPath - Path to the input image
 */
function generateResponsiveVariants(inputPath) {
  const filename = path.basename(inputPath, path.extname(inputPath));
  const ext = path.extname(inputPath).toLowerCase();
  
  // Only process PNG and JPEG files
  if (!['.png', '.jpg', '.jpeg'].includes(ext)) {
    return;
  }
  
  console.log(`Generating responsive variants for ${path.basename(inputPath)}`);
  
  try {
    // Create a directory for this specific image if it doesn't exist
    const imageDir = path.join(RESPONSIVE_DIR, filename);
    if (!fs.existsSync(imageDir)) {
      fs.mkdirSync(imageDir, { recursive: true });
    }
    
    // Generate variants for each size and quality
    for (const size of IMAGE_SIZES) {
      for (const quality of IMAGE_QUALITIES) {
        const outputFilename = `${filename}-${size}w-${quality.name}.webp`;
        const outputPath = path.join(imageDir, outputFilename);
        
        // Skip if this variant already exists
        if (fs.existsSync(outputPath)) {
          console.log(`Skipping ${outputFilename} - already exists`);
          continue;
        }
        
        console.log(`Creating ${outputFilename}`);
        
        // Generate the responsive variant using cwebp with resizing
        execSync(
          `cwebp -resize ${size} 0 -q ${quality.quality} "${inputPath}" -o "${outputPath}"`, 
          { stdio: 'inherit' }
        );
        
        // Also create a fallback version for non-WebP support
        if (quality.name === 'high') {
          const fallbackExt = ext === '.png' ? '.png' : '.jpg';
          const fallbackFilename = `${filename}-${size}w${fallbackExt}`;
          const fallbackPath = path.join(imageDir, fallbackFilename);
          
          if (!fs.existsSync(fallbackPath)) {
            // Use ImageMagick's convert for the fallback (assumes it's installed)
            try {
              execSync(
                `convert "${inputPath}" -resize ${size}x ` +
                (ext === '.png' ? '' : `-quality ${quality.quality} `) +
                `"${fallbackPath}"`,
                { stdio: 'inherit' }
              );
            } catch (error) {
              console.error(`Warning: Could not create fallback image. Is ImageMagick installed? Error: ${error.message}`);
              console.error('Install with: brew install imagemagick');
            }
          }
        }
      }
    }
    
    console.log(`✓ Generated responsive variants for ${path.basename(inputPath)}`);
  } catch (error) {
    console.error(`Error generating responsive variants for ${path.basename(inputPath)}: ${error.message}`);
  }
}

/**
 * Process all images in the static images directory
 */
function processImages() {
  try {
    // Check if cwebp is installed
    if (!checkCwebpInstalled()) {
      return;
    }
    
    const imageFiles = glob.sync(path.join(IMAGES_DIR, '*.{png,jpg,jpeg}'));
    
    // Filter out the hashed versions and already created WebP versions
    const originalImages = imageFiles.filter(file => {
      const basename = path.basename(file);
      return !/-[a-f0-9]{32}\.(png|jpg|jpeg)$/.test(basename) && !basename.endsWith('.webp');
    });
    
    console.log(`Found ${originalImages.length} images to process`);
    
    // Process each image
    for (const imagePath of originalImages) {
      generateResponsiveVariants(imagePath);
    }
    
    console.log('Responsive image generation complete!');
    console.log('To use these images, import the ResponsiveImageHelper in your templates.');
  } catch (error) {
    console.error(`Error processing images: ${error.message}`);
  }
}

// Run the processor
processImages(); 