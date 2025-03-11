const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const glob = require('glob');

// Source and destination directories
const STATIC_DIR = path.join(__dirname, '../../priv/static');
const IMAGES_DIR = path.join(STATIC_DIR, 'images');
const WEBP_QUALITY = 80; // Adjust quality as needed

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
 * Converts an image to WebP format using cwebp command line tool
 * @param {string} inputPath - Path to the input image
 */
function convertToWebP(inputPath) {
  const filename = path.basename(inputPath, path.extname(inputPath));
  const outputPath = path.join(IMAGES_DIR, `${filename}.webp`);
  
  // Skip if WebP version already exists
  if (fs.existsSync(outputPath)) {
    console.log(`Skipping ${filename} - WebP already exists`);
    return;
  }
  
  // Only process PNG and JPEG files
  const ext = path.extname(inputPath).toLowerCase();
  if (!['.png', '.jpg', '.jpeg'].includes(ext)) {
    return;
  }
  
  console.log(`Converting ${path.basename(inputPath)} to WebP`);
  
  try {
    // Use cwebp command line tool
    execSync(`cwebp -q ${WEBP_QUALITY} "${inputPath}" -o "${outputPath}"`, { stdio: 'inherit' });
    
    // Get original and new file sizes
    const originalSize = fs.statSync(inputPath).size;
    const webpSize = fs.statSync(outputPath).size;
    const savings = ((originalSize - webpSize) / originalSize * 100).toFixed(2);
    
    console.log(`✓ Converted ${path.basename(inputPath)} to WebP (${savings}% smaller)`);
  } catch (error) {
    console.error(`Error converting ${path.basename(inputPath)}: ${error.message}`);
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
    
    // Filter out the hashed versions (they have a pattern like name-[hash].ext)
    const originalImages = imageFiles.filter(file => {
      const basename = path.basename(file);
      return !/-[a-f0-9]{32}\.(png|jpg|jpeg)$/.test(basename);
    });
    
    console.log(`Found ${originalImages.length} images to process`);
    
    // Process each image
    for (const imagePath of originalImages) {
      convertToWebP(imagePath);
    }
    
    console.log('Image optimization complete!');
  } catch (error) {
    console.error(`Error processing images: ${error.message}`);
  }
}

// Run the image processor
processImages(); 