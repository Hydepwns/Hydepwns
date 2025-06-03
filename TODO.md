# TODO: Refactoring and Improvements

This document tracks the prioritized refactoring and improvement tasks for the codebase.

---

## 1. Data Consistency and Assigns Handling

- [ ] Audit all LiveViews and components for how assigns are set and accessed.
- [ ] Ensure all assigns are Ecto structs or maps with atom keys (never string keys).
- [ ] Remove any code that converts structs to string-keyed maps unless required for external APIs.
- [ ] Standardize assign setting (e.g., always use `assign(socket, :foo, value)`).

## 2. Theme Management Logic

- [x] Move all fallback/default theme creation logic from LiveViews to `ThemeSystem`.
- [x] Implement `ThemeSystem.ensure_default_theme/0` (or similar).
- [x] Replace all direct theme creation in LiveViews with a call to this function.
- [x] Audit and refactor all LiveViews/components to use `ThemeSystem.ensure_default_theme/0` for `theme_class` assignment, removing hardcoded or fallback theme logic. All theme assignment is now centralized and consistent.

## 3. Template and Component Robustness

- [ ] Audit all templates/components for direct map key access.
- [ ] Add pattern matching or guards to prevent runtime errors.
- [ ] Use `@enforce_keys` in structs where possible.

## 4. Error Handling and Logging

- [ ] Centralize error handling (e.g., a helper for flash messages).
- [ ] Use consistent logging levels and messages.
- [ ] Ensure all user-facing errors are clear and actionable.

## 5. Test Coverage and Test Data

- [ ] Ensure all test data uses Ecto structs, not ad-hoc maps.
- [ ] Add tests for edge cases (empty lists, nils, etc.).
- [ ] Refactor test helpers to enforce data shape.

## 6. Componentization and DRY Principles

- [ ] Extract repeated UI (theme cards, color swatches) into components.
- [ ] Remove duplicated logic in LiveViews/components.

## 7. Accessibility and UX

- [ ] Add ARIA labels and keyboard navigation to interactive elements.
- [ ] Ensure all actions provide feedback (loading, success, error).

## 8. Documentation and Type Specs

- [ ] Add `@doc` and `@spec` to all public functions.
- [ ] Document expected assigns/data shapes for LiveViews/components.

## 9. Configuration and Environment Handling

- [ ] Centralize environment checks (e.g., `Mix.env()`).
- [ ] Remove unnecessary test/dev-specific code.

## 10. Performance and Query Optimization

- [ ] Audit queries for N+1 issues.
- [ ] Add indexes/optimize queries in `ThemeSystem` as needed.

---

**Tip:**
Start with data consistency and theme management logic, as these are the foundation for robust, maintainable, and error-free code.
