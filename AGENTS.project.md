# eTaxVN — Project Engineering Instructions

**Project:** eTaxVN
**Repository:** haibt163/viettax
**Production:** https://etaxvn.vercel.app/
**Effective:** 30 September 2026

These project-specific instructions sit below AGENTS.md and tailor the shared governance to eTaxVN.

## 1. Product definition

eTaxVN is an independent Vietnamese personal income tax estimation tool.

Primary user value:
- make Vietnamese PIT rules easier to understand;
- guide users through inputs needed for an estimate;
- present results clearly in Vietnamese and English;
- provide a calm, trustworthy, mobile-friendly experience.

The product is not a tax filing service, government portal, government account system or substitute for professional tax advice.

## 2. Source-of-truth hierarchy

When facts conflict, use this order:

1. Current committed implementation and tests, for describing what the software currently does.
2. Current approved product specification and repository legal/source notes.
3. Primary Vietnamese legal instruments and official guidance, for legal behavior.
4. Approved PR/issue decisions that deliberately change product behavior.
5. Chat history, screenshots and model memory — context only.

Never silently replace a repository rule with remembered behavior.

## 3. Legal and tax-change protocol

A request to update tax rules is an investigation first and implementation second.

Before changing the tax engine:
- identify the controlling legal source;
- identify article/clause and relevant scope;
- distinguish law commencement from tax-year application;
- identify resident/nonresident and income-category scope;
- identify transition rules;
- add regression tests;
- run the full regression set after implementation.

When legal treatment remains genuinely uncertain:
- keep current behavior unchanged;
- document the uncertainty;
- obtain an explicit product decision before choosing among materially different interpretations.

## 4. Current production surface

### 4.1 Calculator

Primary production UI:
`public/viettax.html`

Root routing:
`/` -> `/viettax.html`

Do not rename `public/viettax.html` without a coordinated routing, SEO, sitemap, verification and deployment update.

### 4.2 Production assets

Important production assets include:
- `public/robots.txt`
- `public/sitemap.xml`
- Google Search Console verification file
- eTaxVN icon family
- `public/site.webmanifest`

Treat these as linked production surfaces. Check paths after changes.

### 4.3 SEO

Current canonical calculator URL:
`https://etaxvn.vercel.app/viettax.html`

Keep canonical, sitemap and social metadata aligned until a deliberate route migration is approved.

Do not allow stale VietTax branding to re-enter public metadata.

## 5. UI/UX rules

The current design direction is a premium, trustworthy Vietnamese fintech-style calculator:
- deep navy and gold identity;
- warm off-white background;
- Be Vietnam Pro plus Fraunces;
- restrained borders and shadows;
- strong mobile hierarchy;
- touch-friendly controls;
- prominent, intelligible tax results.

Do not redesign the visual language during unrelated functional work.

Do not shrink typography merely to pack more information into a screen. Prefer information hierarchy, layout and spacing changes.

## 6. Calculator-engine preservation

The tax engine is currently embedded in the standalone HTML document.

For every change touching calculator behavior:
1. locate the calculation logic;
2. identify the dedicated self-test hook;
3. run the regression set before the change when practical;
4. make the smallest coherent change;
5. run the same regression set after the change.

Never clean up formulas during UI-only work.

## 7. Testing expectations

For calculator behavior changes:
- all T1-T12 baseline cases remain valid unless their legal basis is deliberately changed;
- add a targeted edge case for the changed rule;
- confirm no JavaScript runtime errors;
- confirm VI and EN remain functional;
- confirm the 390px-class layout remains usable.

For repository-wide changes, use:
```
npm run typecheck
npm run lint
npm test
npm run build
node scripts/browser-smoke.mjs
```

Record actual outcomes.

## 8. Data and privacy posture

Default product posture is local calculation and local draft persistence.

Do not send salary, investment, family or tax inputs to a server merely for convenience.

Cross-device saving, accounts and user history are future product features requiring a separate product decision, authenticated ownership and privacy review.

## 9. Mobile packaging direction

Android/iOS packaging is a future track, not part of the current web baseline.

When that work starts:
- reuse the established calculator behavior;
- avoid separate platform tax formulas;
- preserve offline-capable calculation where practical;
- reuse the existing icon and manifest family;
- add native platform capabilities around shared behavior;
- test each platform independently before store submission.

## 10. Grant and competition positioning

eTaxVN may be submitted to startup, fintech, financial-literacy or civic-technology programs.

Applications must describe only verified product capabilities and evidence.

Do not claim:
- government affiliation;
- tax filing integration;
- user counts or impact metrics that have not been measured;
- partnerships that have not been confirmed;
- legal certification that has not been obtained.

## 11. Documentation expectations

README.md should serve:
- future engineers;
- reviewers;
- grant/competition evaluators;
- the Project Owner.

Where useful, distinguish:
**Verified**, **Planned**, and **Unverified**.

## 12. Definition of done

A substantive change is ready for Chief Engineer review when:
- scope is documented and controlled;
- implementation or documentation is coherent;
- relevant verification has actually run;
- evidence is available;
- known risks are stated;
- Git branch/commit state is clear;
- PR names author and reviewer lanes.

Do not merge this branch directly to main.
