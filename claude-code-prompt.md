# Claude Code – Leftover Legends Frontend Implementation Prompt

You are working on a React web app called **Leftover Legends** — a food waste tracking app with a gamification system (Seeds, streaks, ranks). The codebase uses React with all styling done via inline styles in JSX (no separate CSS files, no Tailwind, no CSS modules). Animations are defined as keyframe strings injected via a `<style>` tag inside the component.

The full task list is in `leftover-legends-todo.md`. Work through it **strictly in order: Easy → Medium → Hard**. Do not skip ahead. Complete and verify each item before moving to the next.

---

## Global Design Direction (apply from task #1 onwards)

The app is moving from a dark green theme to a **light mode Penn State-inspired aesthetic**. This applies to every task you touch — do not build anything in the old dark theme. The THEME object below is the single source of truth for all colors. Define it at the top of each file you work in and reference it throughout.

```js
const THEME = {
  bg: '#E3D7C1',           // Tradition Tan — page background
  navy: '#001E44',         // Nittany Navy — primary accent, headings, nav active state
  orange: '#FF7A00',       // Action Orange — CTA buttons, FAB, highlights, active indicators
  slate: '#75787B',        // Victory Slate — muted text, secondary labels, inactive nav
  surface: '#FFFFFF',      // Card and sheet surfaces
  border: '#E0D8C8',       // Subtle borders on light surfaces
  white: '#FFFFFF',
  // Status colors — DO NOT CHANGE THESE UNDER ANY CIRCUMSTANCES
  danger: '#C05050',       // Expiring tomorrow
  warn: '#E8A838',         // Expiring within ~5 days
  good: '#6BAF7A',         // Fresh
};
```

### Key visual rules (follow these on every screen you touch):
- **Background:** `#E3D7C1` — no dark radial gradients, no dark backgrounds
- **Cards:** `#FFFFFF` surface with a soft `box-shadow: 0 2px 12px rgba(0,0,0,0.08)` — no dark borders
- **Headings and primary text:** `#001E44` navy
- **Secondary / muted text:** `#75787B` slate
- **CTA buttons and FAB:** `#FF7A00` orange
- **Active nav state:** `#001E44` navy label + `#FF7A00` orange indicator dot
- **Inactive nav:** `#75787B` slate at reduced opacity
- **Remove:** all dark gradients (`#1A1F1C`, `#242c27`, `#1a1f1c` etc.), dark borders, and glow blobs
- **Keep unchanged:** all status colors, all animation logic, all gamification logic, font (Nunito)

---

## Ground Rules

1. **Frontend only.** This is strictly a frontend pass. If a task requires backend data (e.g. persisted user region, saved food locations, real recipe links), do NOT implement the backend logic. Instead, leave a clearly visible comment like:
   ```js
   // TODO (BACKEND): This will need a backend endpoint to persist the user's selected region
   ```
   Then implement the frontend UI/UX using hardcoded placeholder data or local React state so the interface is complete and ready to connect.

2. **Do not change status colors.** `#C05050` (red), `#E8A838` (yellow), `#6BAF7A` (green) are functional and must stay exactly as-is across all tasks.

3. **Inline styles only.** Match the existing code style — all styles go inline or in the top-level keyframe style string. Do not introduce CSS files, Tailwind, or styled-components.

4. **Always use the THEME constants object.** It is defined in the Global Design Direction section above. Never hardcode color values directly into components — always reference `THEME.navy`, `THEME.orange`, etc.

5. **Comment your changes.** Add a short comment above each block you add or modify referencing the todo item number, e.g. `// TODO #6 – bottom nav readability`.

---

## Task Execution Order

Work through `leftover-legends-todo.md` in this exact order:

### 🟢 Easy (do these first)
- [ ] #1 Blank emoji as default
- [ ] #2 Replace App Store / Play Store buttons with website URL
- [ ] #3 "?" info button on recipe screen with color legend tooltip
- [ ] #4 Swap food photos in marketing infographic with app screenshot placeholder
- [ ] #5 Recipe color semantics — expiring (red), missing (grey), available (green)

### 🟡 Medium (only start after all Easy tasks are done)
- [ ] #6 Bottom nav readability — size, contrast, navy active + orange indicator
- [ ] #7 Prep time + recipe link on recipe cards
- [ ] #8 Better filtering — by food type and expiration date, soonest-to-expire first by default
- [ ] #9 Tutorial section on landing/hero page
- [ ] #10 Unit display — conditionally render kcal vs kJ, imperial vs metric based on selected region
  ```js
  // TODO (BACKEND): Region preference should eventually come from the user's profile/session
  // For now, use local React state defaulting to 'US'
  ```

### 🔴 Hard (only start after all Medium tasks are done)
- [ ] #11 Light mode refactor — full audit pass
  - By this point all new components should already use THEME tokens. This task is a full audit of both JSX files to catch any remaining dark theme values that were not touched in earlier tasks
  - Refactor in this order: hero page → home cards → nav → bottom sheet → FAB
  - Replace any remaining dark gradients with flat light surfaces
  - Ensure all cards are white background + `box-shadow` instead of dark borders
  - Remove any leftover glow blobs or dark ambient effects

- [ ] #12 Food storage location tag (Fridge / Pantry)
  - Clickable tag on each food item card, toggles location on click
  - Add location field to the add-item page UI
  - Add location filter to the fridge contents filter tabs
  ```js
  // TODO (BACKEND): Food item location should be persisted per item in the database
  // Use local React state for now, defaulting all items to 'Fridge'
  ```

- [ ] #13 Region selection screen at sign-in
  - Build the UI screen with region options (e.g. US / Switzerland)
  - On selection, store in React state/context and pass to unit display logic (item #10)
  ```js
  // TODO (BACKEND): Region selection should be saved to the user's profile on sign-in
  // TODO (BACKEND): Currency formatting by region will also need backend support
  ```

---

## Additional Notes

- Education content tab: when SUPSI delivers the content as markdown or JSON, a section/tab will need to be built to render it. **Do not build this yet** — leave a placeholder comment:
  ```js
  // TODO (BACKEND + CONTENT): Education tab — awaiting markdown/JSON content delivery from SUPSI
  ```
- Italian translation is pending review — do not hardcode any Italian strings yet.
- Marketing infographic screenshot swap (item #4): use a clearly labelled placeholder `<div>` styled to match the app's look until the real screenshot is ready.
