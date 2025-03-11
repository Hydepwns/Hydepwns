/**
 * Custom esbuild configuration to enable code splitting.
 * 
 * This configuration builds the JavaScript assets with support for dynamic imports,
 * resulting in separate bundles that are loaded on demand.
 */
const esbuild = require('esbuild');
const { nodeFileTrace } = require('@vercel/nft');
const fs = require('fs');
const path = require('path');

// Define build configuration options
const commonConfig = {
  entryPoints: ['js/entrypoints/app.js'],
  bundle: true,
  minify: process.env.NODE_ENV === 'production',
  sourcemap: process.env.NODE_ENV !== 'production',
  target: ['es2020'],
  outdir: '../priv/static/assets',
  splitting: true, // Enable code splitting
  format: 'esm',   // Use ES modules for dynamic imports
  metafile: true,  // Generate metadata for bundle analysis
  loader: {
    // Define loaders for various file types
    '.js': 'jsx',
    '.png': 'file',
    '.jpg': 'file',
    '.jpeg': 'file',
    '.gif': 'file',
    '.svg': 'file',
    '.woff': 'file',
    '.woff2': 'file',
    '.ttf': 'file',
    '.eot': 'file',
  },
  plugins: [
    // Custom plugin for logging build results
    {
      name: 'build-logger',
      setup(build) {
        build.onEnd(result => {
          if (result.errors.length) {
            console.error('Build failed with errors:');
            result.errors.forEach(error => {
              console.error(error);
            });
          } else {
            console.log(`Build completed successfully in ${result.duration}ms`);
            
            // Analyze bundle if metadata is available
            if (result.metafile) {
              const outputs = Object.keys(result.metafile.outputs);
              
              // Log outputs
              console.log('\nGenerated bundles:');
              outputs.forEach(output => {
                const size = result.metafile.outputs[output].bytes;
                const formattedSize = (size / 1024).toFixed(2) + ' KB';
                console.log(`- ${path.basename(output)} (${formattedSize})`);
              });
            }
          }
        });
      }
    }
  ],
  define: {
    'process.env.NODE_ENV': `"${process.env.NODE_ENV || 'development'}"`,
  },
};

// Development build with watch option
const devBuild = async () => {
  // Start the build in watch mode
  const buildContext = await esbuild.context({
    ...commonConfig,
    outdir: '../priv/static/assets', // Output directory relative to this file
    logLevel: 'info',
  });
  
  // Start watching
  await buildContext.watch();
  console.log('Watching for changes...');
};

// Production build
const prodBuild = async () => {
  try {
    const result = await esbuild.build({
      ...commonConfig,
      outdir: '../priv/static/assets',
      minify: true,
      sourcemap: false,
    });
    
    // Analyze production bundles
    if (result.metafile) {
      fs.writeFileSync(
        'bundle-analysis.json', 
        JSON.stringify(result.metafile)
      );
      console.log('Bundle analysis written to bundle-analysis.json');
    }
  } catch (error) {
    console.error('Build failed:', error);
    process.exit(1);
  }
};

// Run the appropriate build based on environment
if (process.env.NODE_ENV === 'production') {
  prodBuild();
} else {
  devBuild();
}

// Export the configuration for potential reuse
module.exports = commonConfig; 