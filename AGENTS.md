# eTaxVN — Engineering Agent Contract

**Effective:** 30 September 2026
**Scope:** Entire repository unless a deeper AGENTS.md or AGENTS.project.md says otherwise.

This is the repository-level engineering contract for eTaxVN. Read it before making changes.

## 1. Product and repository purpose

eTaxVN is a public Vietnamese personal income tax (PIT) estimation web application.

- Production: https://etaxvn.vercel.app/
- Calculator: https://etaxvn.vercel.app/viettax.html
- Repository: https://github.com/haibt163/viettax

The current production calculator is the standalone document public/viettax.html. The TanStack/Vite scaffold around it remains part of the repository and deployment environment.

The product is an independent calculator/estimator. Never imply that eTaxVN is an official Vietnamese government tax service, government-affiliated product, filing portal, or tax-account integration.

## 2. Engineering roles and approval boundary

The Project Owner is the final human authority.

Main Engineer lanes may include Claude Code, Codex CLI/App, OMP CLI, Grok Build, or another explicitly selected engineering environment. Main Engineers implement and produce evidence.

Chief Engineer review may be performed by Claude Chat or ChatGPT. These are peer review lanes with equal governance standing.

**Author != approver:** the lane that authored a change may not be the lane that approves that change for merge into main.

No implementation lane should merge its own unreviewed work into main.

Every substantive pull request must state:
- author lane;
- reviewer lane;
- scope;
- verification evidence;
- known risks or unverified items.

For chat-based review without direct repository access, use the standard handoff:
```
git status
git log -5 --oneline --decorate
git show --stat --oneline HEAD
run the repository ZIP snapshot script
handoff ZIP + Git state + verification output
```

Treat chat history as context only. Durable engineering truth is repository content, Git history, pull requests, tests, CI and runtime evidence.

## 3. Working rules

### Before implementation

1. Read this file and AGENTS.project.md.
2. Inspect live Git state and the current branch.
3. Read README.md and relevant source before changing behavior.
4. Classify the task as implementation, documentation, audit, or release preparation.
5. Preserve existing product intent unless the task explicitly changes it.
6. For tax-law behavior, identify the exact legal source and effective period before modifying calculation logic.

### During implementation

- Prefer small, coherent feature branches.
- Never allow two coding agents to edit the same worktree simultaneously.
- Keep unrelated cleanup out of focused changes.
- Do not rewrite the product merely because the scaffold contains unused capabilities.
- Preserve working production behavior while improving the repository.
- Keep scripts and user instructions separate from explanatory comments.
- Put Project Owner commands in proper Markdown code blocks.

### Before handoff

- Run relevant tests and verification commands.
- Report actual results; never call work fixed, passing, complete, or production-ready without evidence.
- Record unresolved risks and assumptions.
- Keep the change easy to review and audit.

## 4. Production application contract

### 4.1 Primary calculator

public/viettax.html is the current production calculator document.

The root route currently redirects / to /viettax.html.

Do not rename it casually. A rename requires coordinated updates to routing, SEO, sitemap, verification files, deployment and documentation.

Internal local-storage and test identifiers may still use the historical viettax_* naming. Do not rename them solely for branding without an explicit migration plan.

### 4.2 Branding

The user-facing brand is eTaxVN.

Avoid reintroducing VietTax in visible product copy, page titles, SEO metadata, share metadata or documentation except where discussing historical implementation names.

Use precise wording around official sources. Legal references may be described as being based on identified laws/regulations when actually sourced. Do not invent government endorsement or integration.

### 4.3 Language

The calculator is Vietnamese-first with English support. Preserve its translation structure and language preference behavior.

### 4.4 Privacy

The core calculator should remain client-side and should not transmit users' financial/tax inputs merely to calculate tax.

Do not add analytics, telemetry, remote logging, external form submission or personal-data collection without explicit product authorization and privacy review.

### 4.5 Mobile direction

The product is web-first. PWA/installability and future Android/iOS packaging are separate product tracks.

Do not duplicate tax formulas between web and native platforms. Shared calculation behavior is the source to preserve.

## 5. Tax-law integrity — highest-priority domain rule

This is a financial/tax application. Calculation correctness and legal provenance outrank cosmetic improvements.

Never modify tax constants, thresholds, rates, exemptions, deduction rules, residency rules, effective dates or taxable-income treatment from memory alone.

For every tax-law change:

1. Identify the exact law, decree, circular, resolution or official guidance supporting the change.
2. Record the effective date and tax period separately when they differ.
3. State the affected income category and taxpayer population.
4. Add or update deterministic tests.
5. Preserve an audit trail in Git and the PR description.
6. Run the complete regression suite.

The original product specification was based on Law 109/2025/QH15 and may not include every later 2026 instrument. Do not assume that the general commencement date is the tax period for every income category.

Legal content is product logic, not casual editorial text.

## 6. Current tax-engine baseline

The current calculator implements the rules captured by the existing product specification and implementation for:
- resident/nonresident classification;
- salary/wage income;
- business income;
- rental income;
- capital/dividend and securities income;
- real-estate income;
- prizes, royalties, inheritance and other income;
- deductions and annual progressive salary tax;
- bilingual presentation.

The product baseline includes T1-T12 regression cases from the original specification. Preserve them unless the underlying legal basis is deliberately revised with documented evidence.

Do not change formulas during an unrelated UI task.

## 7. Architecture

Current repository areas include:
- public/ — deployed static assets and the primary calculator;
- src/ — TanStack/Vite application shell and reusable/platform helpers;
- scripts/ — build, migration, browser-smoke, brand and environment tooling;
- server/ — platform middleware;
- migrations/ — optional/auth database schema;
- vercel.json — deployment configuration.

The root route redirects to /viettax.html.

The repository contains Better Auth, database and PGLite helpers inherited from the platform scaffold. Their existence does not mean eTaxVN should add accounts or persistent user data. Add those features only for an explicit product requirement and follow the existing isolation rules.

## 8. Verification standard

Use:
- **VERIFIED** — direct repository, command, test, CI or runtime evidence;
- **UNVERIFIED** — proposal, inference or claim lacking direct evidence;
- **FAILED** — confirmed failure.

For substantive changes, use applicable checks:
```
npm run typecheck
npm run lint
npm test
npm run build
node scripts/browser-smoke.mjs
```

For calculator behavior changes, also run the standalone calculator self-test hook when available and report exact results.

For browser work, verify desktop and mobile rendering, visible content, console errors and horizontal overflow. A 200 HTTP response is not render verification.

## 9. Security and secrets

- Never commit secrets, API keys, credentials, .env files or private keys.
- Respect .gitignore.
- Review public/static additions for accidental sensitive information.
- Do not add third-party scripts or network dependencies without documenting purpose and privacy impact.

## 10. Git and branch discipline

- main is the protected product baseline by process even if GitHub settings do not enforce it.
- Use a feature branch for substantive work.
- Keep commits coherent and descriptive.
- Do not force-push shared branches unless explicitly authorized.
- Do not rewrite history just for aesthetics during review.
- Use a PR as the merge boundary for substantive changes.

## 11. Review ZIP and handoff

create-project-zip-universal.ps1 is the standard review snapshot tool.

For a real Chief Engineer review handoff, include the Git state, verification output and the required ZIP contents according to the current engineering governance. Do not treat a source ZIP as a substitute for tests or runtime evidence.

## 12. Scope control

Agents should not:
- add a backend because the scaffold contains one;
- add accounts merely because auth helpers exist;
- introduce analytics or ads without authorization;
- change legal rules during visual polish;
- rename the primary calculator without a coordinated route/deployment plan;
- delete platform files casually;
- declare completion without evidence.

## 13. Handoff format

For implementation:
```markdown
# Implementation Handoff
## Task
## Scope
## Design
## Changes
## Tests / Verification
## Evidence
## Remaining Risks
## Unverified
## Git
Branch:
Commit:
PR:
Author lane:
Reviewer lane:
```

For audits:
```markdown
# Audit Report
## Scope
## Repository State
## Method
## Findings
## Evidence
## Verification Status
### VERIFIED
### UNVERIFIED
### FAILED
## Risks / Concerns
## Unresolved Questions
## Recommendations
## Changes Made
## Handoff
```
