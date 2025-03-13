# Documentation Update Process

This document outlines the process for updating, maintaining, and reviewing documentation in the Hydepwns project.

## Documentation Structure

The Hydepwns documentation is organized in a PRD (Product Requirements Document) structure:

```
docs/
├── PRD/                    # Main documentation directory
│   ├── ARCHITECTURE/       # System architecture documentation
│   ├── DESIGN/             # Design principles and guidelines
│   ├── DEVELOPMENT/        # Development guides and processes
│   ├── DEPLOYMENT/         # Deployment and operations documentation
│   ├── FEATURES/           # Feature-specific documentation
│   └── PROJECT_MANAGEMENT/ # Project management documents (roadmap, etc.)
├── DOCUMENTATION_MAP.md    # Map of documentation locations
└── README.md               # Documentation overview
```

## Documentation Update Workflow

Follow these steps when updating or adding documentation:

1. **Identify the Appropriate Location**
   - Use the `DOCUMENTATION_MAP.md` to find where existing documentation lives
   - For new documentation, choose the appropriate subdirectory in the PRD structure
   - Related documentation should be grouped together

2. **Create or Update Documentation**
   - Use markdown format with consistent styling
   - Follow the templates provided in `docs/DOCUMENTATION_META_TEMPLATE.md`
   - Include all required sections (Purpose, Audience, Content)
   - Use header hierarchy consistently (# for title, ## for major sections)

3. **Include Required Elements**
   - Title and description at the top
   - Table of contents for longer documents
   - Appropriate cross-references to related documentation
   - Code examples where relevant
   - Diagrams or images for complex concepts

4. **Validate Documentation**
   - Run `node scripts/docs/validate_documentation.js` to check for issues
   - Run `node scripts/docs/generate_index.js` to update indexes and check links
   - Fix any issues reported by the validation scripts

5. **Update Documentation Indexes**
   - Ensure new documentation is referenced in `DOCUMENTATION_MAP.md`
   - Add entry to relevant index files in subdirectories
   - Update the main `docs/PRD/README.md` if adding a major document

6. **Submit for Review**
   - Create a PR with your documentation changes
   - Complete the documentation section in the PR template
   - Request review from team members with domain expertise

## Documentation Standards

All documentation should follow these standards:

### Formatting

- Use consistent markdown formatting throughout
- Break lines at 100 characters for better readability in raw form
- Use code blocks with language specification (```elixir)
- Use tables for structured data
- Use bulleted or numbered lists for sequences and options

### Structure

- Start with a clear title and brief description
- Include a table of contents for documents longer than 200 lines
- Group related information under clear headings
- Use a consistent header hierarchy
- End with relevant references or "see also" sections

### Content

- Write in clear, concise language
- Target the appropriate technical level for the intended audience
- Include examples where helpful
- Document both "how" and "why"
- Update date stamps when making significant changes

## PR Checklist for Documentation Changes

Before submitting a PR that includes documentation changes, ensure:

- [ ] Documentation follows the project's structure and templates
- [ ] All internal links are valid
- [ ] Code examples are correct and tested
- [ ] No spelling or grammar errors
- [ ] Documentation indexes are updated
- [ ] `node scripts/docs/generate_index.js` has been run
- [ ] `node scripts/docs/validate_documentation.js` passes
- [ ] Documentation accurately reflects the current state of the code
- [ ] Added appropriate tags/categories to the documentation

## Automated Documentation Maintenance

The project uses several scripts to maintain documentation quality:

- **generate_index.js**: Updates documentation indexes and validates internal links
- **validate_documentation.js**: Checks documentation for formatting and structural issues
- **doc_migration_status.js**: Tracks progress of legacy documentation migration

Run these regularly and before submitting PRs with documentation changes:

```bash
# Generate and update documentation indexes
node scripts/docs/generate_index.js

# Validate documentation formatting and structure
node scripts/docs/validate_documentation.js

# Check documentation migration status
node scripts/docs/doc_migration_status.js
```

## Documentation Review Process

Documentation changes follow this review process:

1. **Initial Review**: Technical accuracy and completeness
2. **Structural Review**: Organization, cross-references, and adherence to templates
3. **Language Review**: Clarity, conciseness, and correctness
4. **Final Verification**: Ensuring all validation scripts pass

At least one reviewer with domain expertise must approve documentation changes before merging.

## Documentation Update Schedule

- **Feature Documentation**: Updated with feature implementation
- **Architecture Documentation**: Updated when architectural changes occur
- **Process Documentation**: Reviewed quarterly and updated as needed
- **General Guide**: Refreshed monthly with recent changes and improvements

## Legacy Documentation Migration

The project is in the process of migrating legacy documentation to the PRD structure:

1. Identify legacy documentation to migrate
2. Create new file in appropriate PRD subdirectory
3. Update content to match current templates and standards
4. Add to documentation map and indexes
5. Create PR to add new file and deprecate old location
6. Update references to point to new location

Track migration progress using `node scripts/docs/doc_migration_status.js`. 