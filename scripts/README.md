# Scripts Directory

This directory contains utility scripts used for development, building, and maintaining the Hydepwns project.

## Script Categories

The scripts are organized into the following categories:

### Build Scripts

Scripts related to building and compiling assets:

- `build/css_builder.sh` - Compiles CSS using PostCSS and Tailwind
- `build/esbuild.config.js` - Configuration for esbuild JavaScript bundling

### Asset Tools

Scripts for managing and optimizing assets:

- `assets/optimizers/image_optimizer.js` - Optimizes images for web delivery
- `assets/generators/responsive_image_variants.js` - Generates responsive image variants

### Documentation Tools

Scripts for maintaining and validating documentation:

- `docs/generate_index.js` - Generates documentation index and validates links
- `docs/validate_documentation.js` - Checks for broken links and formatting issues
- `docs/doc_migration_status.js` - Reports on documentation migration progress

## Usage

Each script includes usage instructions at the top of the file. Generally, scripts can be run from the project root using:

```bash
./scripts/[category]/[script_name]
```

## Script Documentation Standards

Each script in this directory should have comprehensive documentation:

1. **In-Script Documentation**:
   - Include a header comment section with script purpose, usage, and author
   - Document functions and complex logic with comments
   - Add usage examples in comments

2. **External Documentation**:
   - For complex scripts, create a dedicated markdown documentation file
   - Use the template at `scripts/docs/SCRIPT_DOCUMENTATION_TEMPLATE.md`
   - Save documentation with same name as script but with `.md` extension

Example of a well-documented script header:

```javascript
#!/usr/bin/env node

/**
 * Script Name: example_script.js
 * 
 * Purpose: Brief explanation of what this script does
 * 
 * Usage:
 *   ./scripts/category/example_script.js [options]
 * 
 * Options:
 *   --option1=VALUE   Description of option1
 *   --option2=VALUE   Description of option2
 * 
 * Examples:
 *   ./scripts/category/example_script.js --option1=value
 * 
 * Author: Developer Name
 * Created: YYYY-MM-DD
 * Updated: YYYY-MM-DD
 */
```

## Adding New Scripts

When adding a new script to this directory:

1. Place it in the appropriate category subdirectory
2. Make sure it has executable permissions (`chmod +x script_name`)
3. Include a header comment with purpose and usage instructions
4. Update this README with a description of the script
5. For complex scripts, create a dedicated documentation file using the template
6. Run automated documentation validation with `./scripts/docs/validate_documentation.js`

## Script Documentation Maintenance

The script documentation is maintained using the following:

1. **Validation**: Run `node scripts/docs/validate_documentation.js` to check that all scripts have proper documentation
2. **Template**: Use `scripts/docs/SCRIPT_DOCUMENTATION_TEMPLATE.md` for creating detailed documentation
3. **Updates**: When modifying a script, update its documentation and the last updated date

## Best Practices

- All scripts should be executable and have a shebang line
- Include error handling and helpful error messages
- Use consistent formatting and style
- Add usage examples in comments
- Make scripts work from any directory (use absolute paths)
- Follow the single responsibility principle - scripts should do one thing well
- Add logging capabilities with different verbosity levels
- Include version information and help text
- Validate inputs and provide meaningful error messages 