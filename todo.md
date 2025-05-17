# Project Improvement Plan

_A concise, actionable checklist for continuous improvement. Update as you progress._

---

## Top Priority

### 1. CI/CD & Quality

- [ ] Ensure GitHub Actions run: `mix format --check-formatted`, `mix test`, `mix credo --strict`, `mix dialyzer`.
- [ ] Add ExCoveralls for test coverage; report in CI.
- [x] Improve test reliability for LiveView theme manager (tests now passing, validation errors rendered)
- [ ] Enforce code formatting in CI and locally (pre-commit hook).

### 2. Documentation

- [ ] Expand `README.md`: project overview, setup, usage, badges, directory structure.
- [ ] Add/update `CONTRIBUTING.md`, `CHANGELOG.md`.
- [ ] Ensure all public modules/functions have `@moduledoc`/`@doc`.


---

## Medium Priority

### 4. Structure & Dependencies

- [ ] Refactor/group modules for clarity; remove unused files.
- [ ] Audit/update dependencies in `mix.exs`; run `mix deps.audit`.

### 5. Developer Experience

- [ ] Add `bin/setup` for onboarding.
- [ ] Provide editor config recommendations (e.g., `.vscode/`).

---

## Lower Priority

### 6. Observability & Performance

- [ ] Integrate Telemetry for metrics.
- [ ] Improve structured logging.
- [ ] Profile and optimize as needed.

### 7. Frontend & Assets

- [ ] Optimize asset pipeline (esbuild, Dart Sass).
- [ ] Audit UI for accessibility (ARIA, keyboard, contrast).

### 8. Advanced

- [ ] Prepare for Hex publishing (metadata, docs, versioning).
- [ ] Add example projects/Livebook notebooks.
- [ ] Add Docker support (`Dockerfile`, `docker-compose.yml`).

### 9. Maintenance

- [ ] Enable Dependabot for deps.
- [ ] Add issue/PR templates and triage process.

---

## Immediate Next Steps

1. Review CI for linting, tests, formatting, coverage.
2. Audit secrets; update `.env.example` and docs.
3. Run Credo/Dialyzer; fix major issues.
4. Improve test coverage.
5. **LiveView theme manager tests are now green and validation errors are visible in the UI.**

---

_Keep this document up to date as improvements are made. Prioritize foundational items first for maximum impact._

---
