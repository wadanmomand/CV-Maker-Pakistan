# CV Maker Pakistan — Windows Agent Build Prompt (DEBUG APK ONLY, v1.0.0+1)

Copy this whole prompt to the Windows agent. Do not add features, do not change the locked name or package, do not build a signed AAB in this run.

## 0. First step — verify the package before you touch any code

Extract the tarball. Print the directory tree. STOP unless you see exactly this structure:

```
cv-maker-pakistan-build/
  AGENT-PROMPT.md
  plan/APP_PLAN.md
  icons/cv-icon-final-512.png
  screens/01-home.webp
  screens/02-form-personal.webp
  screens/03-template-pick.webp
  screens/04-preview-a4.webp
  screens/05-samples.webp
  screens/06-settings.webp
```

Read `cv-maker-pakistan-build/plan/APP_PLAN.md` in full. It is the specification. The screen images in `screens/` are the approved designs. The built app must match them 100% in layout, colours, and button positions, except for the corrections in section 3 below, which override the images.

If any file above is missing, STOP and report which file is missing. Do not guess a replacement image or icon.

## 1. Locked identity — check in 4 places, stop on any mismatch

- App name: CV Maker Pakistan
- Play title: CV Maker Pakistan
- Package / applicationId: com.aatishstudio.cvmaker — no underscores, no variation
- Developer: Aatish Studio
- Category: Business
- Version for this build: 1.0.0+1

After creating the Flutter project, verify the locked id in ALL of these, and stop the build if any one differs:
1. The `namespace` in android/app/build.gradle.kts
2. The `applicationId` in android/app/build.gradle.kts
3. The package in AndroidManifest.xml
4. The package of MainActivity

Treat a Flutter template default as suspect when it contains underscores. The locked id removes underscores, and a template default otherwise ships silently. In your final report, name the installed package from a device/emulator check, not only the source package.

## 2. What to build — Flutter, fully offline, zero backend

Build a Flutter app with these screens, in this order:
1. Home / My CVs
2. Create/Edit — 10-step form: Personal, Objective, Education, Experience, Skills, Languages, Projects, Certifications, References, Hobbies
3. Template Pick — 4 templates only
4. Live A4 Preview
5. Samples
6. Settings / Privacy

Plus PDF Share/Download, locked in Home (card overflow menu) and in Preview.

Rules — hard, no exceptions:
- No Firebase, no server, no API, no account, no login, no email verification, no cloud sync.
- Storage: on-device SQLite only. Photo (optional) stored locally only, deleted with its CV.
- PDF: generated on-device with the Flutter pdf package. Real selectable text, A4 size, NO watermark, NO ads on the PDF.
- Backup: local JSON export via the system share sheet only, and JSON import via file picker only. No auto cloud backup.
- Share: only via the system share sheet when the user taps Share. The app never auto-sends anything.
- Ads: TEST AdMob banner IDs only, on the Home screen only. No production AdMob IDs in this build. No ads on the preview or on the PDF.
- Language: Roman Urdu default + English toggle, applied immediately, no restart. CV output itself is in English.
- Theme: LIGHT default, dark/light toggle in Settings, applied immediately, no restart.
- Data model: CV { id, title, template, photo_path nullable, created_at, updated_at } plus child rows for personal (single), education[], experience[], skills[], languages[], projects[], certifications[], references[], hobbies[].
- Templates v1 (4 only, all free, no Pro badge, no paywall): Classic ATS single-column (default), Modern two-column, Minimal, Photo CV.
- Samples v1 (6 only, all free): Teacher, Nurse, Bank Clerk, IT Graduate, Govt Job, Shop/Sales. Sample text must be original, written for Pakistan roles. Do NOT copy sample text from competitor apps.
- Out of v1 — do NOT build, do NOT list: AI writing, cover letter builder, Word (.docx) export, LinkedIn import, job-board integration, cloud sync, account, Urdu-script PDF output.

## 3. Corrections that override the concept images — build these, not the image flaws

1. Home bottom ad: the Home concept image shows "Upgrade to Pro – Remove ads & unlock AI review". REJECTED. There is no Pro tier and no AI review in v1. Home bottom = TEST banner ad placeholder only.
2. Template Photo CV subtitle: the Template concept image shows a garbled word "plakeloder". REJECTED. Built text is "Includes photo". Check every template subtitle word-by-word before building.
3. US example data: the Form and Preview concept images use US examples (Taylor Morgan, Alex Morgan, San Francisco, New York, University of Washington, +1 numbers). REJECTED. Built examples and sample data are Pakistan only: e.g. Ahmed Khan, 03xx-xxxxxxx, Peshawar / Karachi / Lahore. No US sample data ships in the app.
4. Form step indicator: the Form concept shows only 3 steps. REJECTED as a fixed row. The real form has 10 steps (section 2 above). Use scrollable step chips or "Step X of 10" + progress bar.
5. CNIC: NO CNIC field in v1. Do not add one.
6. Form validation: Next is blocked ONLY if Full Name or Phone is empty, with a clear inline error. No other field blocks Next.
7. Settings cloud icons: the Settings concept shows cloud up/down icons for Backup/Restore. REJECTED as implying cloud backup. Built Backup/Restore is a local JSON file only. Use a share/file icon, or keep the arrow with text "Export JSON (local file)".
8. Sample Personal data: Use Sample creates a NEW CV, never overwrites an existing CV, fills role sections with editable example text, and leaves Personal contact fields (Name, Phone, Email, City, Address, Photo) BLANK. After Use Sample, open the form at Step 1 Personal. Never ship a sample with a fake person's name/contact that a user could export by mistake.
9. Preview: preview must match the PDF exactly (WYSIWYG) — same template, same order, same text, same photo placement. A difference between preview and PDF is a bug. Empty sections are hidden, not shown as blank headings. If the CV exceeds 2 pages, show a soft warning only, NOT a hard block.
10. Template change: changing template must NOT delete entered data, only re-layout it.
11. Delete: CV card Delete and Settings Delete All Data both require confirmation. Settings Delete All Data requires TWO-step confirmation, says it cannot be undone, wipes SQLite + local photos, and returns to the Home empty state.
12. Listing safety (do not put these in any in-app text or listing draft): never "Best", "#1", "Top", "premier", "get hired 2x faster", or "ATS guaranteed". Say "clean format that ATS systems can read", not "ATS approved". No job guarantee, no fake testimonials.

## 4. Screen-by-screen behaviour (from APP_PLAN sections 11–16)

- Home: emerald header, gold Create New CV button, Sample CVs chips, CV cards with Edit + PDF + overflow menu (Duplicate, Rename, Share PDF, Delete with confirm), empty state when no CVs, TEST banner only.
- Form: emerald header, Back, Create CV / Edit CV, Save (saves draft to SQLite + "Saved" toast, stays on form). Next also autosaves. Every field change autosaves to SQLite (debounced). Closing the form, switching steps, or returning to Home never loses entered data. On Step 1, Back returns to Home — draft is already autosaved, so no discard dialog is needed. On the last step, Next becomes "Preview".
- Template Pick: 2x2 grid, Classic default selected with gold border + gold check badge. Use Template saves the choice to this CV and goes to Preview.
- Preview: A4 page, page indicator (Page 1 of 1 / Page 1 of 2, swipe/scroll for page 2), bottom buttons Edit, Template, Share, Download PDF. Download saves the PDF to device Downloads + toast with the file name. Share opens the system share sheet.
- Samples: vertical list, emerald circle role icon (simple line icon, NOT emoji), role name, one-line description, gold Use Sample button. List scrolls to all 6 roles.
- Settings: Language (Roman Urdu / English), Theme (Light / Dark), Backup Export JSON, Restore Import JSON (validate the file; on import ask Replace all / Merge, default suggestion Merge; invalid file = clear error, no data change), Privacy Policy (bundled in-app text, works offline, developer Aatish Studio), About (Version 1.0.0, Developer Aatish Studio), Delete All Data (section 3, item 11). No login, no account row, no Pro/upgrade row.

## 5. Stale-refresh rule — verify without a restart

Home list reloads from SQLite every time Home becomes visible again, not only on first build. After Create, Edit, Duplicate, Rename, or Delete, invalidate and reload before Home is shown. The user must NEVER need to restart the app to see a change.

Your report must name each of these flows, the screen opened after the change, and whether the change appeared without a restart:
- Create a CV → return to Home → new CV visible
- Edit a CV title → return to Home → new title visible
- Delete a CV → return to Home → card gone
- Delete All Data in Settings → return to Home → empty state visible
A report that only names a code change or a test count, without these no-restart checks, is incomplete.

## 6. Icon

Install `icons/cv-icon-final-512.png` (512x512, gold fountain pen nib on white CV page, deep emerald green full-bleed background) as the app icon in all Android mipmap densities. Do NOT use any other icon file from the drafts. Do NOT programmatically remove a background from any icon. After installing the icon, run flutter analyze and confirm it is clean.

## 7. Tests, analyze, and build — DEBUG APK ONLY

- Run `flutter analyze` — must be clean (0 errors).
- Write and run real unit tests, at minimum: multi-CV CRUD, template change preserves data, PDF generation produces real text with no watermark, JSON backup export/import round-trip, sample creates a new CV with blank Personal fields.
- Report the exact test count and result (e.g. "X/Y tests passed").
- Build a DEBUG APK only. Do NOT build a signed AAB in this run. Do NOT create a keystore in this run. Do NOT put any keystore, password, or credential in the repo, in the prompt reply, or in chat. If a credential is needed later for a signed build, the user will supply it directly to a Windows agent session at that time, never in Muse chat.
- Future release note (do NOT act on it now): a release build must set minify/shrink explicitly false, OR set them true only with WorkManager/Room ProGuard keep rules wired, because R8 shrinking has stripped WorkManager Room code in past Play builds and crashed at startup. A release report without a bundletool universal-APK launch test is not verification.

## 8. Repo, branch, and push — one consolidated push, no merge

- Repo: the user will create the GitHub repo before you run, or tell you its exact name in this session. If the repo does not exist, STOP and report that it is missing. Do not invent a repo name and do not create one on your own.
- Proposed repo name (use only if the user confirms it in this session): wadanmomand/cv-maker-pakistan
- Branch: create a new branch for this build (for example feat/cv-maker-full). Commit all Flutter code, the plan reference, the icon, and the screen concepts used.
- Push ONCE, in a single consolidated push, then open a pull request to main. Do NOT merge the PR without an explicit user order. Do NOT push staggered fixes while the user is mid-build.
- Never commit key.properties, *.jks, passwords, or API keys. Check .gitignore covers them before pushing.

## 9. Final report — required, in this format

Your report must include, or it is incomplete:
1. `git rev-parse HEAD` SHA of the pushed branch, and confirmation that it equals the latest commit on that branch.
2. The PR link, and confirmation the PR is OPEN and NOT merged.
3. flutter analyze result (0 errors, or list every error).
4. Test count and result (X/Y passed).
5. DEBUG APK path and size in bytes.
6. Installed package name from a device/emulator check, confirming it is com.aatishstudio.cvmaker.
7. The 4 stale-refresh flows from section 5, each with "appeared without restart: yes/no".
8. Screenshots ATTACHED to your chat report (not file:// links, not local paths alone) showing: Home (with at least one CV), Form Step 1, Template Pick, Preview, Samples, Settings.
9. Any deviation from APP_PLAN sections 11–16, with the reason, or the words "No deviations".

Push step (mandatory, last step):
```
git push -u origin <branch-name>
```
Then paste the PR link in your report. Do not stop at a local commit.
