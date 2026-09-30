# eTaxVN

**Vietnamese Personal Income Tax Calculator — 2026**

eTaxVN is an independent web calculator that helps people estimate Vietnamese personal income tax (PIT) through a guided, bilingual experience.

**Live:** https://etaxvn.vercel.app/
**Calculator:** https://etaxvn.vercel.app/viettax.html
**Repository:** https://github.com/haibt163/viettax

## What it does

The calculator guides a user through the information needed for an estimate, including:
- residency status;
- salary and wage income;
- business income;
- rental income;
- investment and other income categories;
- deductions;
- a tax result and breakdown.

The interface is Vietnamese-first with English support and is designed for desktop and mobile use.

## Important legal note

eTaxVN is an **independent estimation tool**. It is not an official Vietnamese government tax portal and is not a tax filing service.

Calculations reflect the legal/product rules currently committed to this repository. Tax laws and administrative guidance can change. Material filing decisions should be checked against current official sources or a qualified tax professional.

The general effective date of a law is not automatically the tax period applied to every income category. Legal updates therefore require separate review of commencement, tax-year and transition provisions.

## Current status

### Verified

- A public production deployment exists at the URLs above.
- The standalone calculator is committed at `public/viettax.html`.
- `robots.txt`, `sitemap.xml`, and Google Search Console verification are present.
- eTaxVN icon and PWA assets are committed under `public/`.
- Automated build, migration, browser-smoke and repository tooling are present.

### Planned

- Fresh legal/tax-engine audit against the latest applicable 2026 Vietnamese instruments.
- Android/iOS packaging.
- Competition and grant submissions.
- Product improvements driven by measured user feedback.

### Not currently claimed

This repository does not claim:
- government affiliation;
- tax filing submission;
- live tax-account integration;
- cross-device user accounts;
- measured public adoption or impact metrics.

## Engineering governance

eTaxVN uses a multi-lane engineering workflow.

**Main Engineer lanes:** Claude Code, Codex CLI/App, OMP CLI, Grok Build and other explicitly selected implementation environments.

**Chief Engineer review lanes:** Claude Chat and ChatGPT as peer review lanes.

**Project Owner:** final human authority.

The author of a change does not approve that same change for merge to `main`.

Read:
- `AGENTS.md` — repository engineering contract.
- `AGENTS.project.md` — eTaxVN-specific instructions.

## Repository map

```text
viettax/
├── AGENTS.md
├── AGENTS.project.md
├── README.md
├── public/
│   ├── viettax.html              # production calculator
│   ├── robots.txt
│   ├── sitemap.xml
│   ├── site.webmanifest
│   └── eTaxVN icons / verification
├── src/
│   ├── routes/                   # TanStack application shell
│   ├── lib/                      # auth/data/platform helpers
│   └── components/
├── scripts/                      # build, QA, migration and support tools
├── migrations/                   # auth/database migration assets
├── server/                       # platform middleware
├── package.json
├── package-lock.json
├── vercel.json
└── create-project-zip-universal.ps1
```

## Local development

The repository is a Vite/TanStack workspace.

```bash
npm ci
npm run dev
```

Useful checks:

```bash
npm run typecheck
npm run lint
npm test
npm run build
node scripts/browser-smoke.mjs
```

The current site root redirects to the standalone calculator document.

## Git workflow

Use a dedicated feature branch for substantive work.

A normal handoff includes:

```
git status
git log -5 --oneline --decorate
git show --stat --oneline HEAD
```

Then run the repository ZIP snapshot script and provide verification output with the review package.

## Product principles

**Correct before clever.** Tax behavior must be legally sourced and regression-tested.

**Transparent before official-looking.** eTaxVN must never imply government affiliation.

**Web-first before platform duplication.** New mobile surfaces should reuse established calculator behavior.

**Evidence before claims.** Repository, test and runtime evidence outrank model memory or marketing language.

## License

No public license is currently declared. Treat the repository as all-rights-reserved unless an explicit license is added later.
