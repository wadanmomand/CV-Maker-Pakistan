# CV Maker Pakistan — APP PLAN (v1, zero backend)

Status: STARTED 2026-10-27, user pick from no-backend shortlist.
Developer: Aatish Studio (locked name for all listings/privacy pages).
Builder pattern: Muse direct, same as Mobile Khata / School Ultra / Madrasa Ultra
(one screen at a time, user verdict before next screen).

## 1. Name / identity — LOCKED 2026-10-27 22:41 PKT (user tap)
- App name: **CV Maker Pakistan**
- Play title: **CV Maker Pakistan**
- Package: `com.aatishstudio.cvmaker`
  - Follows Aatish Studio pattern (com.aatishstudio.mobilekhata, .schoolultra, .madrasaultra).
  - Short form preferred over com.aatishstudio.cvmakerpakistan.
- Category: **Business** — most CV apps in Play check (2026-10-27) list Business;
  Productivity/Education also appear, Business is the job-application fit.
- Language: Roman Urdu default + English toggle
  (same as Mobile Khata / School Ultra; NOT Urdu script — that is Madrasa Ultra only).
- Theme: LIGHT default (user preference 2026-10-12), dark/light toggle stays.
- Icon: FINAL 2026-10-27 — Option E, gold fountain pen nib on white CV page, deep emerald green full-bleed background. Source: icons/media-generation-cv-icon-e-pen-nib-*.webp (1600x1600). Final Play PNG: icons/cv-icon-final-512.png (512x512, 56 KB, verified). Other options A-D, F archived in icons/ as drafts, NOT final.

## 2. Play check — 2026-10-27 (search, not a Play Console availability check)
- Exact title "CV Maker Pakistan" NOT found as an existing Play title.
- Generic competitors DO exist and must be differentiated against, not copied:
  - "CV Maker : Resume Builder" (CODEMATICS, Pakistan, rating 3.4, 158 reviews in one locale listing)
  - "Resume Builder - CV Maker App" (offline, no login, PDF/JPEG export, cover letter)
  - "Resume CV PDF Maker" (offline, multiple CVs, cover letter)
  - "Resumify - AI CV Maker" (AI angle — out of scope for v1, AI needs backend/API)
- Honest correction to 2026-10-27 shortlist pitch: "most CV apps need login" is NOT true.
  Several competitors are already offline/no-login. Differentiation is therefore NOT
  "offline" alone — it is the combination in section 4.

## 3. Zero-backend rule — HARD
- No Firebase, no server, no API, no account, no login, no email verification.
- Storage: on-device SQLite only. Photo (optional) stored locally only.
- PDF: generated on-device (Flutter pdf package), real selectable text, not a screenshot image.
- Backup: local JSON export via share sheet only (user-initiated). No auto cloud sync in v1.
- Share: only via system share sheet (WhatsApp, Gmail, Drive, print) when user taps Share.
  App never auto-sends anything.
- Ads: TEST AdMob IDs only in v1 (production AdMob blocked 2026-10-14, same as other apps).
  No ads on the PDF itself, no watermark on PDF.
- Privacy claim for listing: "Your CV data never leaves your phone unless you share the PDF yourself."
  This is truthful only if the rule above is kept — no analytics SDK that uploads CV fields.

## 4. Differentiation (why this wins vs generic CV apps)
1. **Free PDF, no watermark, no paywall on download** — the most common complaint/lock in competitors.
2. **Pakistan sample CVs, pre-filled examples** — Teacher, Nurse, Bank/Clerk, IT/Fresh Graduate,
   Govt job format, Shop/Sales — with Roman Urdu guidance on what to write in each section.
3. **Multiple CVs, one per job** — duplicate a CV, tailor it, keep old versions. Competitors have this
   too, so it is table stakes, not the headline.
4. **ATS-friendly template as default** — clean single-column, standard headings, real text
   (NOT a guarantee: listing must never say "ATS guaranteed" or "get hired 2x faster").
5. **Roman Urdu guidance + English CV output** — UI guidance in Roman Urdu, CV itself in English
   (Urdu-script CV output is Phase 2 only if user orders it; do not promise it in v1 listing).

## 5. MVP scope — v1 only (do NOT add in v1)
IN:
- My CVs list (create, duplicate, rename, delete, open)
- Step form: Personal, Objective/Summary, Education, Experience, Skills, Languages,
  Projects (optional), Certifications (optional), References (optional), Hobbies (optional)
- Photo: optional, round/square crop, stored locally. Photo ON/OFF per CV.
- Templates v1 (4 only): Classic ATS (single-column, default), Modern (two-column),
  Minimal, Photo CV (Pakistan/Gulf style)
- Live A4 preview + page count (warn if >2 pages)
- Export: PDF download + share, JSON backup export/import
- Samples: 1 sample CV per role above, "Use this sample" fills the form (editable)
- Settings: language toggle, theme toggle, Privacy/About, Delete all data

OUT of v1 (do not build, do not list):
- AI writing / AI improvement (needs API + cost + backend)
- Cover letter builder (Phase 2 — competitors have it, but scope control wins v1)
- Word (.docx) export, LinkedIn import, job-board integration
- Cloud sync, account, cloud backup
- Urdu-script PDF output (font/RTL risk — Phase 2 only)

## 6. Screens — one at a time, user verdict each (do NOT batch)
1. Home / My CVs
2. Create/Edit — step form (Personal first)
3. Template pick
4. Live A4 preview
5. PDF share/download + My CVs actions
6. Samples
7. Settings / Privacy
Icon is separate from screens — user verdict on icon options before build package.

## 7. Data model (local only)
CV { id, title, template, photo_path (nullable), created_at, updated_at }
Sections as child rows: personal (single), education[], experience[], skills[],
languages[], projects[], certifications[], references[], hobbies[]
- No CNIC field in v1 form by default. If user orders it later, it must be optional,
  never required, and listing must say it stays on-device.
- Delete CV = delete its rows + local photo file. Delete all = wipe DB + photos.

## 8. Play policy — lessons carried over
- NO ranking claims in listing: never "Best", "#1", "Top", "premier", "get hired 2x faster"
  (Muslim Ultra 'premier' violation 2026-10-27; Bijli/Gas Misleading Claims fixes 2026-10-23/24).
- NO job guarantee, NO ATS guarantee. Say "clean format that ATS systems can read" — not "ATS approved".
- NO fake testimonials, NO copied sample CV text from competitors.
- Data Safety: No data collected, No data shared with third parties (only true if section 3 holds;
  AdMob test IDs aside, re-check before submission if any SDK is added).
- Privacy page: Aatish Studio, same pattern as VidBaaz/Bijli/Gas pages on portfolio site.
- Size target: keep under ~60 MB if possible, but NO strict size lock (School Ultra 2026-10-27
  dropped the under-60 MB lock — do not promise a size number in listing).

## 9. Build / release checklist (later, in order)
- Flutter project, package above, version 1.0.0+1
- analyze clean + real unit tests (PDF generation, multi-CV CRUD, JSON backup round-trip)
- Debug APK → phone QA (user) → signed AAB
- Keystore: C:\Users\muham\cvmaker-upload.jks (to be created, user MUST back up .jks + credentials)
- Repo: to be created (proposed wadanmomand/cv-maker-pakistan, visibility user decision)
- Play: listing + privacy page + Data Safety, TEST ads only until production AdMob unblocked

## 11. Home screen spec — FINAL 2026-10-28 (user tap "Home concept final karo")
Concept image: design/media-generation-cv-home-screen-concept-*.webp
Layout (top to bottom, must match concept 100% in built app unless user orders a change):
1. Header: deep emerald green (Icon E colour), gold pen icon left, "My CVs" title, Settings gear right.
   UI language in concept is English for readability; built app default is Roman Urdu + English toggle.
2. Gold "Create New CV" button, full width, below header.
3. "Sample CVs" strip: horizontal chips Teacher, Nurse, Bank, IT (+ Govt/Shop in built list,
   concept shows 4 for space). Tap a chip = fill form from that sample, editable, then Save as new CV.
4. CV list: white cards, soft shadow, light cream background. Each card shows:
   CV title, template name (Classic/Modern/Minimal/Photo), last edited date,
   Edit button + PDF button (download/share).
   Concept shows only Edit + PDF; built card MUST also have overflow (3-dot) menu:
   Duplicate, Rename, Share PDF, Delete (with confirm dialog). No swipe-to-delete in v1.
5. Empty state (not in concept image, must be built): pen illustration + "Abhi koi CV nahi hai"
   + "Apna pehla CV banayen" button + Sample CVs chips below it.
6. Bottom: TEST AdMob banner only. CORRECTION to concept image: the image's bottom ad text
   "Upgrade to Pro – Remove ads & unlock AI review" is WRONG for v1 and must NOT be built.
   No Pro tier, no AI review in v1 (both OUT of scope, section 5). Banner = test ad placeholder only.
STALE-REFRESH RULE (flutter_stale_screen_refresh skill, locked for this screen):
- Home list reloads from SQLite every time Home becomes visible again, not only on first build.
- After Create, Edit, Duplicate, Rename, or Delete, the list is invalidated and reloaded before
  Home is shown — user must NEVER need to restart the app to see the change.
- Verification for this screen: create a CV → return to Home without restart → new CV visible;
  edit title → return → new title visible; delete → return → card gone. Agent report must name
  each of these flows, not just "tests passed".

## 12. Create/Edit form spec — FINAL 2026-10-28 (user tap "Form concept final karo")
Concept image: design/media-generation-cv-form-screen-concept-*.webp — shows Step 1 Personal only.
Layout (must match concept in colours/spacing, with the corrections below):
1. Header: emerald green, Back arrow left, "Create CV" title (Edit mode: "Edit CV"), Save right.
   Save = save draft to SQLite + "Saved" toast, stays on form. Next also autosaves before moving.
2. Step indicator: concept shows only Step 1 Personal / Step 2 Objective / Step 3 Education.
   CORRECTION: built form has 10 steps — Personal, Objective, Education, Experience, Skills,
   Languages, Projects, Certifications, References, Hobbies. Indicator must be scrollable chips
   or "Step 1 of 10" + progress bar, NOT a fixed 3-step row, or user will think the form ends at Education.
3. Step 1 Personal fields (in this order):
   - Photo: circular placeholder, camera icon, "Add Photo — optional". Tap = gallery pick, crop
     round/square per template. Photo stored locally only, deleted with CV. Photo ON/OFF per CV.
   - Full Name (required), Phone Number (required), Email (optional but recommended),
     City (required, Pakistan city), Address (optional, short only).
   - NO CNIC field in v1 (plan section 7). NO Date of Birth required; if added later, optional only.
   - Validation: Next is blocked only if Full Name or Phone is empty, with a clear inline error.
     No other field blocks Next.
4. Example/hint text CORRECTION: concept image uses US examples (Taylor Morgan, +1 number,
   San Francisco, 123 Main St). Built app MUST use Pakistan examples and Roman Urdu hints,
   e.g. Name hint "Ahmed Khan", Phone hint "03xx-xxxxxxx", City hint "Peshawar, Karachi, Lahore...".
   Do NOT ship US examples.
5. Bottom: Back (white outline) + Next (gold). On Step 1, Back returns to Home — draft is already
   autosaved, so no "discard?" dialog is needed. On last step, Next becomes "Preview".
6. Draft rule: every field change autosaves to SQLite (debounced). Closing the form, switching
   steps, or returning to Home never loses entered data. Home list refresh rule (section 11)
   applies on return: edited title appears without restart.
7. Roman Urdu: field labels in built app follow the app language toggle — Roman Urdu default,
   English toggle. Concept image is English for readability only.

## 13. Template pick spec — FINAL 2026-10-28 (user tap "Template concept final karo")
Concept image: design/media-generation-cv-template-pick-concept-*.webp
Layout:
1. Header: emerald green, Back arrow, "Choose Template". Subtitle: "Pick a resume template to get started".
2. 2x2 grid, white cards, soft shadow, light cream background:
   - Classic (top left, DEFAULT selected): single column, gold border + gold check badge.
     This is the ATS-friendly default. Text under it: "Single column".
   - Modern (top right): two-column, emerald sidebar + white main column.
   - Minimal (bottom left): clean, lots of white space, thin lines only.
   - Photo CV (bottom right): circular photo placeholder at top of page.
3. Bottom: gold "Use Template" button, full width. Tap = save template choice to this CV
   (SQLite), go to Live A4 Preview. Template can be changed later from Preview / Edit —
   changing template must NOT delete entered data, only re-layout it.
4. CORRECTION to concept image: Photo CV subtitle in the image reads "Includes photo plakeloder"
   — garbled AI text, must NOT be shipped. Built text: "Includes photo" (or Roman Urdu equivalent
   under the language toggle). All other template subtitles must be checked word-by-word before build.
5. Thumbnails in built app must show the real structure (name line + section lines), not the
   near-blank Classic thumbnail in the concept. Layout, colours, and selected state must match concept.
6. No template is locked behind paywall in v1. All 4 are free. No "Pro" badge on any template.

## 14. Live A4 Preview spec — FINAL 2026-10-28 (user tap "Preview concept final karo")
Concept image: design/media-generation-cv-preview-concept-*.webp
Layout:
1. Header: emerald green, Back arrow, "Preview".
2. Centre: white A4 page with shadow, on light grey background. Page shows, in the chosen
   template: name, contact line, then sections in form order — Objective, Education, Experience,
   Skills, Languages, Projects, Certifications, References, Hobbies — only sections the user
   filled (empty sections are hidden, not shown as blank headings).
3. Page indicator below page: "Page 1 of 1" / "Page 1 of 2" etc, with swipe/scroll to next page
   when CV flows to page 2. If CV exceeds 2 pages, show a soft warning above the buttons:
   "CV 2 pages se zyada hai — kuch sections chota karein" — warning only, NOT a hard block.
4. Bottom buttons: Edit (white outline, returns to form), Template (white outline, returns to
   Template pick, data preserved), Download PDF (gold).
   CORRECTION to concept: concept shows only those 3 buttons. Built screen MUST also have
   Share: after Download, show Share button / or Download button long-press? No — simplest
   locked rule: bottom row = Edit, Template, Share, Download PDF. Download saves PDF to
   device Downloads + toast with file name. Share opens system share sheet (WhatsApp, Gmail,
   Drive, print). No watermark on PDF, real selectable text, A4 size.
5. WYSIWYG rule: preview must match the PDF exactly — same template, same order, same text,
   same photo placement. A difference between preview and PDF is a bug, not a design choice.
6. CORRECTION to concept data: concept page uses US sample data (Alex Morgan, New York,
   University of Washington). Built preview shows ONLY the user's own entered data, or a
   Pakistan sample CV when the user opened a sample. No US sample data ships in the app.

## 15. Samples spec — FINAL 2026-10-28 (user tap "Samples concept final karo")
Concept image: design/media-generation-cv-samples-concept-*.webp
Layout:
1. Header: emerald green, Back arrow, "Sample CVs".
2. Vertical list of white cards, each with emerald circle role icon (simple line icon, NOT emoji),
   role name, one-line description, gold "Use Sample" button.
   Concept shows 4 cards for space: Teacher (School Teacher CV), Nurse (Hospital Nurse CV),
   Bank Clerk (Bank Job CV), IT Graduate (Fresh IT Graduate CV).
   CORRECTION: built list scrolls to 2 more roles — Govt Job and Shop/Sales — total 6 samples,
   matching the MVP list. Do NOT ship with only 4.
3. Use Sample action — LOCKED rule:
   - Creates a NEW CV in My CVs (never overwrites an existing CV).
   - Fills Objective, Education, Experience, Skills, Languages etc with role-appropriate
     Pakistan example text, fully editable in the form.
   - Personal contact fields (Name, Phone, Email, City, Address, Photo) stay BLANK for the
     user to fill. Sample must NOT ship with a fake person's name/contact that a user could
     export by mistake.
   - After Use Sample, open the form at Step 1 Personal so the user fills their own details first.
4. Sample text must be original, written for Pakistan roles (e.g. Teacher: B.Ed / school subjects;
   Nurse: hospital ward / patient care; Bank: cash handling / customer service; IT: programming
   languages / projects; Govt: clerical / office work; Shop: sales / stock). Do NOT copy sample
   text from competitor apps. No job guarantee or "get hired" claim in any sample text.

## 16. Settings / Privacy spec — FINAL 2026-10-28 (user tap "Settings concept final karo")
Concept image: design/media-generation-cv-settings-concept-*.webp — last v1 screen.
Rows (in order):
1. Language: Roman Urdu (default) / English. Tap = choice list, applies immediately to all
   screens, no restart. Saved in local settings.
2. Theme: Light (default) / Dark. Tap = choice, applies immediately, no restart.
3. Backup: Export JSON — creates a local JSON file with all CVs and opens system share sheet.
   CORRECTION to concept icons: the cloud up/down icons in the image must NOT imply cloud
   backup. Built action is local file only, no server upload. Icon in built app should be
   share/file icon, or keep arrow but with text "Export JSON (local file)".
4. Restore: Import JSON — file picker, reads a backup JSON created by this app, validates it,
   then asks: Replace all / Merge (add as new CVs)? Default suggestion in dialog: Merge, to
   avoid accidental overwrite. Invalid file = clear error, no data change.
5. Privacy Policy: opens bundled in-app privacy text (works offline). Text must match the
   Play listing privacy page: data stays on device, no account, no cloud, PDF shared only
   when user taps Share, TEST ads only. Developer: Aatish Studio.
6. About: Version 1.0.0, Developer Aatish Studio, app name CV Maker Pakistan.
   No login, no account row, no Pro/upgrade row in v1.
7. Delete All Data: red outline row at bottom. Tap = TWO-step confirm:
   first dialog "Saara data delete ho jayega?" then type/confirm "Delete". Action wipes SQLite
   + local photos, returns to Home empty state (section 11 stale-refresh applies — Home must
   show empty state without restart). This action cannot be undone — dialog must say so.

## 17. ALL v1 SCREENS FINAL — 2026-10-28 checklist
- Icon: Option E FINAL (pen nib, emerald)
- Home: FINAL (section 11)
- Create/Edit Form: FINAL (section 12)
- Template Pick: FINAL (section 13)
- Live A4 Preview: FINAL (section 14, + Share/Download locked)
- Samples: FINAL (section 15)
- Settings / Privacy: FINAL (section 16)
No v1 screen remains unapproved. Next step is build, not another screen concept.
Open for build: repo creation (proposed wadanmomand/cv-maker-pakistan), repo visibility,
keystore creation + backup, Flutter build env, agent prompt vs Muse direct build.

## 10. Open decisions — ask ONE at a time, in this order
1. Name + package + category lock — DONE 2026-10-27 22:41 PKT
2. Icon style — DONE 2026-10-27, Option E FINAL
3. Home screen concept — DONE 2026-10-28, FINAL (emerald header, gold Create button, Sample chips, CV cards with Edit+PDF+overflow menu, empty state, stale-refresh rule, TEST banner only — no Pro/AI ad text)
4. Templates: confirm 4, or cut to 3 for faster v1?
5. Cover letter: confirm OUT of v1?
6. Repo visibility + keystore creation timing
