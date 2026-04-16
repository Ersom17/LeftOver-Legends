# Leftover Legends – Frontend TODO

## 🟢 Easy

1. **Blank emoji as default** — ensure food items default to a blank/neutral icon, not a plate emoji
2. **Replace App Store / Play Store buttons** — swap with a website URL on the marketing/hero page
3. **"?" info button on recipe screen** — small tooltip/modal explaining the color system (red = expiring, yellow = under 5 days, green = fresh, grey = not available)
4. **Swap food photos in marketing infographic** — replace stock food images with actual app screenshots once ready
5. **Recipe color semantics** — clearly distinguish expiring (red), missing ingredient (grey), and available item (green) in recipe cards

---

## 🟡 Medium

6. **Bottom nav readability** — increase font size, improve contrast; use `#001E44` navy for active state with `#FF7A00` orange indicator dot
7. **Prep time + recipe link** — add estimated prep time and a clickable link on each recipe card
8. **Better filtering** — filter by food type and expiration date; default sort = soonest-to-expire at top
9. **Tutorial on landing/hero page** — short walkthrough or explainer section showing how the app works
10. **Unit display by region** — conditionally show kcal vs kJ and imperial vs metric based on region selected at sign-in

---

## 🔴 Hard

11. **Light mode refactor (Penn State aesthetic)** — full styling overhaul using the brand palette below. Replace all dark inline styles across both JSX files:
    - Background: `#E3D7C1` (Tradition Tan)
    - Primary accent / nav / headings: `#001E44` (Nittany Navy)
    - CTA buttons / FAB / highlights: `#FF7A00` (Action Orange)
    - Muted text / secondary labels: `#75787B` (Victory Slate)
    - Card surfaces: `#FFFFFF` with `box-shadow` (no dark borders)
    - Keep status colors as-is: `#C05050` red / `#E8A838` yellow / `#6BAF7A` green
    - **Implementation tip:** Create a central `THEME` constants object first — swap tokens once, updates everywhere. Order: hero page → home cards → nav → bottom sheet → FAB

12. **Food storage location tag** — add Fridge / Pantry tag to each food item:
    - Shown as a clickable button on the item card
    - Tapping it toggles/changes the location
    - Also needs to be added to the **add-item page**
    - Must be **filterable** in the fridge contents list

13. **Region selection at sign-in** — "Where are you from?" screen that sets:
    - Unit display (kcal vs kJ, grams/liters)
    - Currency format
    - Must connect to the unit display logic (item 10)

---

## 📌 Notes
- Education content from SUPSI will arrive as **markdown or JSON** — needs a tab/section to render it in-app
- Italian translation corrections pending (Nathan's contact reviewing)
- Marketing infographic layout is done — just needs the app screenshot swap (item 4)
