# Current state (WIP / needs rescue)
- Invoices page from Phase 1 is missing/partially restored.
- Profile info page missing.
- BalanceRing import/pathing was flaky; HomeScreen may have inline/alternate versions.
- Analyzer may still show lints; app compiles but needs cleanup.

Suggested next steps:
1) Restore Phase-1 screens from origin/main selectively (invoices, profile).
2) Keep all app code under apps/mobile/lib/src; avoid root-level lib/.
3) Recreate Request Payment screen behind a feature flag.
