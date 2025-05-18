# Project Improvement Plan

_A concise, actionable checklist for continuous improvement. Update as you progress._

---

## Top Priority

### CI/CD & Quality

- [ ] Ensure GitHub Actions run: `mix format --check-formatted`, `mix test`, `mix credo --strict`, `mix dialyzer`.
- [ ] Enforce code formatting in CI and locally (pre-commit hook).

### Documentation

- [ ] Ensure all public modules/functions have `@moduledoc`/`@doc`.

---

## Medium Priority

### Structure & Dependencies

- [ ] Refactor/group modules for clarity; remove unused files.

## Immediate Next Steps

1. Review CI for linting, tests, formatting, coverage.
2. Audit secrets; update `.env.example` and docs.
3. Run Credo/Dialyzer; fix major issues.
4. Improve test coverage.

---
