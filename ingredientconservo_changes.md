# IngredientConservo — Frontend Changes to Implement

The project already exists. Apply only the changes listed below. Explore the codebase first to understand the existing structure before making any changes.

---

## Onboarding & App Introduction
- Create an introductory tutorial that appears the first time a user opens the app (skippable for returning users)
- It should walk through the 5 core features of the app, one at a time:
  - Pantry Tracking — add groceries and track expiration dates
  - Smart Recipes — get recipe suggestions based on what you have
  - Receipt Scanning — scan receipts to quickly add items
  - Rewards System — earn points and unlock coupons
  - Food Waste Tracking — see your impact in preventing food waste
- After the feature walkthrough, ask the user "Where are you from?" with options for US and Switzerland/Europe — this sets their region for dates, currency, and units throughout the app
- End with a clear "Get Started" button that leads to the main app
- Should take roughly 2–3 minutes to complete

---

## Design System
- Introduce a central theme file with CSS variables for the official brand colors: Dark Green (#3F5E4A), Muted Olive Green (#6E7F5F), Warm Brown/Gold (#B59A6A), Light Beige Background (#F4EFEA), Card Background (#E9E3DC), Soft Gray Text (#7A7A7A), White (#FFFFFF)
- All components should use these variables consistently
- The visual reference for the style is the existing login screen — all pages should match it
- Prepare (but don't activate) a dark mode color palette for future use

---

## Food Entry & Pantry
- Add the ability to edit existing pantry items (name, quantity, expiration date) without having to delete and re-add them
- Make emoji selection optional, not required, when adding a food item
- On mobile, pantry items should display in a single column instead of a crowded grid

---

## Localization
- Date formatting should match the user's region: MM/DD/YYYY for US users, DD/MM/YYYY for EU/Swiss users
- Apply this consistently everywhere dates appear (pantry cards, inputs, receipts, history)
- Replace the existing country/cuisine browse button with a dropdown selector

---

## Recipes
- Add a favorite/save button to recipe cards so users can bookmark recipes
- Show a saved favorites section and a history of recently generated recipes

---

## Receipt Scanning
- Replace all instances of "AI is scanning" with neutral language like "Scanning..."
- Add a note (shown only when relevant) that some receipts may not scan perfectly and items can be added manually

---

## Education Panel
- Add a new "Learn" or "Food Knowledge" tab to the main navigation (currently has 5 tabs)
- Create a placeholder UI for this section — content will be provided by the backend later
- The panel should be aware of the user's region (US vs Swiss), as content will differ

---

## Branding
- Replace all instances of "Leftover Legends" with "IngredientConservo" across the entire app (UI text, page titles, settings, etc.)
- Remove any App Store / Google Play download buttons if present

---

## Rewards
- Add a "Beta" badge to the rewards/wallet section to communicate it's an experimental feature

---

## Testing Checklist
Before marking anything done, verify:
- [ ] All pages use the brand color palette
- [ ] Pantry items can be edited without deletion
- [ ] Dates display in the correct format per region
- [ ] Country selector is a dropdown
- [ ] Recipes can be saved as favorites
- [ ] No "AI is scanning" text in the receipt flow
- [ ] Education tab appears in navigation and renders a placeholder
- [ ] No "Leftover Legends" text anywhere in the UI
- [ ] Pantry shows 1 column on mobile (375px)
- [ ] Rewards section has a Beta label
- [ ] All text is readable in light mode (WCAG AA contrast)
- [ ] Italian language inputs display correctly throughout the session
