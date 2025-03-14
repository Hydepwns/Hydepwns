# Current Documentation Broken Links Report
Generated: 2025-03-14

## Summary
This report identifies broken links in the current (non-archived) documentation. Links are categorized by directory and severity.

## High Priority Fixes

### Getting Started Documentation
These links are critical as they affect new users:

1. In `guides/getting-started/installation.md`:
   - `../../development/contributing/getting-started.md` (Contributing Guide)

2. In `guides/getting-started/index.md`:
   - `../../design/principles.md` (Design Principles) - Should be moved to development/design
   - `../../reference/features/resource-management.md` (Resource Management)
   - `../../project/planning/known-issues.md` (Known Issues)

3. In `guides/getting-started/overview.md`:
   - `../../development/contributing/getting-started.md` (Contributing Guide)

### API Documentation
Critical for developers:

1. In `reference/api/overview.md`:
   - `../../reference/api/authentication.md`
   - `../../reference/api/resources.md`
   - `../../reference/api/transformations.md`
   - `../../reference/api/events.md`
   - `../../reference/api/users.md`
   - `../../reference/api/settings.md`

## Medium Priority Fixes

### Project Documentation
1. In `project/README.md`:
   - `./releases` (Releases directory)
   - `./planning` (Planning directory)
   - `./process` (Process directory)
   - `../development/contributing` (Contributing Guidelines)
   - `../reference/architecture` (Architecture Documentation)

### User Guides
1. In `guides/user-guides/theme-system.md`:
   - `../user-guides/accessibility.md`
   - `../user-guides/user-preferences.md`

### Project Roadmap
1. In `project/roadmap.md`:
   - `../../development/components/migration-guide`
   - `../../project/planning/component-migration-plan`
   - `../../development/testing/component-testing-framework`
   - `../../reference/performance/resource-system-optimization`

## Low Priority Fixes

### Guide Navigation
1. In `guides/README.md`:
   - `./getting-started`
   - `./user-guides`
   - `./tutorials`
   - `../reference/api`

## External Links to Verify
1. GitHub repository links:
   - `https://github.com/hydepwns/api-issues`
   - `https://github.com/owickstrom/the-monospace-web`

2. Status page:
   - `https://status.hydepwns.com`

## Recommendations

1. High Priority Actions:
   - Create missing API documentation files in reference/api/
   - Add contributing guide at development/contributing/getting-started.md
   - Move design principles to development/design/principles.md

2. Medium Priority Actions:
   - Create missing directories (releases, planning, process)
   - Add user guide documentation (accessibility, preferences)
   - Update component migration documentation paths

3. Low Priority Actions:
   - Update navigation links in guides/README.md
   - Verify and update external links

## Next Steps

1. Focus on fixing high-priority broken links first, especially in getting started documentation
2. Create missing API documentation files
3. Update the documentation map to reflect any new file locations
4. Run the link checker again after fixes to verify changes

## Notes
- Some broken links are marked with TODO comments in the source files
- External links should be verified for availability
- Consider implementing automated link checking in the CI/CD pipeline 