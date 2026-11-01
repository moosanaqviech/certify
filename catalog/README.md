# Certify catalog contract

The **single source of truth** for what courses exist. The site generates
`catalog.json` from its actual course content and publishes it at a stable URL;
the mobile app fetches it at runtime. This kills the drift between the site
catalog and the hardcoded `LocalCertRepository` in the app.

- `catalog.schema.json` — JSON Schema (draft 2020-12) both ends validate against.
- `catalog.json` — copy of the live manifest (`generated_at` 2026-10-05, 11 certs),
  refreshed 2026-11-01. `app/assets/catalog.json` is the same file bundled as
  the app's offline fallback.

## The one rule that actually prevents drift

**Generate `catalog.json` from the course content — never hand-edit it.**
If it's typed by hand it becomes a *third* source of truth and drifts again.
The step that builds/ships a course must emit or update this file, so
"course exists on the site ⟹ it's in the manifest, with the real lesson count."

## Publish target

Publish at a stable, CORS-readable URL, e.g. `https://certify.courses/catalog.json`.
Serve with a short `Cache-Control` (e.g. `max-age=300`) so status/count changes
reach users quickly. Validate in CI on every publish:

```bash
# fails the build if the manifest doesn't match the contract
npx ajv-cli validate -s catalog.schema.json -d catalog.json
```

## What is and isn't in the manifest

The manifest is **course/content metadata only**. Two kinds of state are
deliberately excluded and stay on the device, merged onto each cert by `id`:

| Field | Where it lives | Why |
|---|---|---|
| `lessons_total` | **manifest** | same for everyone |
| `status`, colors, `lesson_url`, `units` | **manifest** | describe the course |
| `lessons_done` / progress | **device (local)** | per learner |
| `downloaded` / `downloading` | **device (local)** | per device |

### Optional card/course-sheet fields

These drive the richer catalog card and course sheet. Every one is optional:
the app hides the matching UI when a field is absent, so the generator can
emit them course by course. **Emit only real values** — omit a field rather
than writing `0`, `""` or a placeholder URL.

| Field | Type | Example | App use |
|---|---|---|---|
| `questions_total` | int | `420` | "· 420 questions" on card; stat tile in sheet |
| `mocks_total` | int | `3` | "· 3 mock exams" on card; stat tile in sheet |
| `level` | `foundational` \| `associate` \| `professional` \| `specialty` | `"associate"` | chip on card; "DATABRICKS · ASSOCIATE" in sheet |
| `last_verified` | ISO date | `"2026-09-21"` | "✓ Verified 21 Sep 2026" on card; sheet footer |
| `icon` | `database` \| `ml` \| `genai` \| `analytics` \| `spark` | `"database"` | topic glyph in the card tile (unknown/missing → monogram) |
| `practice_url` | absolute URL | `https://certify.courses/…/practice.html` | "Practice" button (hidden if absent) |
| `ready_url` | absolute URL | `https://certify.courses/…/ready.html` | "Am I ready?" row in sheet (hidden if absent) |
| `guide_url` | absolute URL | `https://certify.courses/…/guide.html` | "Read the exam guide" row in sheet (hidden if absent) |
| `price` | string | `"$9.99"` | price line — **hidden in the app by default** (see below) |
| `price_note` | string | `"one-time unlock after free Unit 1"` | qualifier after the price |

`price`/`price_note` are display-only. The app gates them behind a
`showPrices` flag that is **off**, and never links to a web checkout: selling
digital unlocks from inside the iOS/Android app outside store billing can
breach App Store guideline 3.1.1 and Google Play's payments policy.

The old seed had `lessonsDone: 11` baked in — that must not come from a shared
file, or every user sees the same "11 done." The card's progress ring is
`localProgress(cert.id) / cert.lessons_total`.

## `status` means content availability, not learner progress

This is the deeper fix. The current app `CertStatus` conflates "the user
started this" (`inProgress`) with "content exists." Split them:

| manifest `status` | meaning | app behaviour |
|---|---|---|
| `live` | all lessons published | navigable; learner badge from local progress |
| `authoring` | some lessons live, more being written | navigable |
| `retiring` | live but exam being withdrawn (`available_until`) | navigable; show retirement date |
| `planned` | announced, no content yet | **do not navigate** (today's `comingSoon`) |

The card's "New / In progress / Done" badge is then derived **locally** from
progress, independent of catalog status.

## App-side changes required to consume this

The `Future<List<Cert>>` seam already exists, so the UI doesn't change. The
consuming changes are:

1. **`ApiCertRepository`** that GETs the manifest, with fallback order:
   fresh fetch → last-good cached copy (`shared_preferences`) → bundled
   `assets/catalog.json` (so first launch / offline still shows a catalog).
   Add the asset to `pubspec.yaml`.
2. **Colors are hex now** (`accent`/`ink`), not decimal `accent_argb`/`ink_argb`.
   Parse with a helper: `Color(int.parse(hex.replaceFirst('#',''), radix: 16) | 0xFF000000)`
   (OR-in full alpha when only 6 hex digits are given).
3. **`lessons_done` is no longer in the model's network shape** — default it to
   `0` in `Cert.fromJson` and overlay local progress after loading.
4. **`exam_code` optional** — tolerate `null` (Databricks certs have none).
5. **Extend `CertStatus`** to the vocabulary above (`live`/`authoring`/
   `retiring` all navigable; `planned` = the current non-navigating case).

## Recommended sequence

1. Lock this schema (done — `catalog.schema.json`).
2. Wire the site generator to emit `catalog.json`; publish + CI-validate it.
3. Then build `ApiCertRepository` against the live URL.
