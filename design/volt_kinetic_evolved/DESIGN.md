# Design System Document: Volt Kinetic Evolved

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Kinetic Vault."** 

This system rejects the "standard app" aesthetic in favor of a high-performance, editorial interface that feels like a piece of precision engineering. It balances the raw energy of high-intensity training with the silent, monolithic security of offline-first architecture. 

We break the "template" look through **Kinetic Asymmetry**. Instead of perfectly centered grids, we use weighted layouts where typography and data visualizations drive the composition. Large-scale headings may bleed off-canvas or overlap containers, creating a sense of forward motion. This is not a static interface; it is a dashboard for human evolution.

---

## 2. Colors & Surface Architecture
The palette is built on the tension between the deep, silent `surface` (#0d0e13) and the hyper-active `primary` (#f3ffca).

### The "No-Line" Rule
**Borders are prohibited for sectioning.** To define boundaries, designers must use background color shifts. A training module should sit on a `surface-container-low` section, which itself rests on the `surface` background. This creates a sophisticated, "milled" look rather than a "sketched" one.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. 
- **Base Layer:** `surface` (#0d0e13) – The foundation.
- **Structural Layer:** `surface-container-low` (#121319) – For secondary content blocks.
- **Interactive Layer:** `surface-container-high` (#1e1f26) – For cards and active modules.
- **Active Layer:** `surface-container-highest` (#24252d) – For elements requiring immediate focus.

### The "Glass & Gradient" Rule
To elevate the "high-tech" feel, floating elements (like persistent workout timers) should use **Glassmorphism**. Use `surface-container` colors at 70% opacity with a `24px` backdrop-blur. 

### Signature Textures
Main CTAs must use a **Kinetic Gradient**: a linear transition from `primary` (#f3ffca) to `primary-container` (#cafd00) at a 135-degree angle. This provides a "pulsing" energy that flat colors cannot replicate.

---

## 3. Typography
The typography system utilizes a dual-font strategy to balance technical precision with readability.

*   **Display & Headlines (Space Grotesk):** This is our "Voice." Its idiosyncratic letterforms convey a high-tech, futuristic personality. 
    *   *Usage:* Use `display-lg` for "Big Numbers" (reps, weights) and `headline-md` for workout titles.
*   **Body & Titles (Manrope):** This is our "Utility." It provides a clean, neutral counterweight to the aggressive Space Grotesk.
    *   *Usage:* Use `body-lg` for workout instructions and `title-sm` for data labels.

**Editorial Intent:** Use extreme scale contrast. Pair a `display-lg` weight value with a `label-sm` unit descriptor to create a clear, authoritative hierarchy that is readable from six feet away during a heavy set.

---

## 4. Elevation & Depth
Depth is achieved through **Tonal Layering**, mimicking the look of stealth technology.

*   **The Layering Principle:** Avoid shadows for structural elements. Instead, nest `surface-container-lowest` (#000000) cards within a `surface-variant` (#24252d) container to create "sunken" or "etched" depth.
*   **Ambient Shadows:** For "floating" elements (e.g., a modal), use a diffuse shadow: `Y: 20px, Blur: 40px, Color: rgba(0, 0, 0, 0.5)`. Never use harsh, dark-grey shadows.
*   **The "Ghost Border" Fallback:** If a border is required for accessibility, use the `outline-variant` token at 15% opacity. It should be felt, not seen.
*   **Security Cues:** Privacy indicators (Offline Mode) should use a subtle glow effect using the `secondary` (#00e3fd) token with a `4px` outer blur to signify an active, protected state.

---

## 5. Components

### Buttons
*   **Primary:** Large (min-height: 64px), tactile. Background: Kinetic Gradient (`primary` to `primary-container`). Text: `on-primary-fixed` (#3a4a00). 
*   **Secondary:** Ghost style with a `2px` border using `primary-dim`. 
*   **Tactile Feedback:** On press, buttons should scale down to 97% to simulate physical resistance.

### The "Privacy HUD" (Custom Component)
A persistent, slim status bar at the top or bottom of the screen. 
*   **Color:** `surface-container-lowest`. 
*   **Indicator:** A small, pulsing `secondary` (#00e3fd) dot with the label "LOCAL VAULT ACTIVE" in `label-sm`.

### Cards & Lists
*   **Rule:** No dividers. 
*   **Logic:** Separate list items using an `8px` vertical gap. Each item should have a slightly different surface tone (`surface-container-low` vs `surface-container-high`) to define the edge.

### Workout Input Fields
*   **Style:** Underlined only. Use `primary` for the active underline (2px) and `outline-variant` for the inactive state. 
*   **Typography:** Large `headline-lg` for the numeric value to ensure visibility during movement.

---

## 6. Do's and Don'ts

### Do:
*   **Do** use `primary` sparingly. It is a "high-voltage" accent, not a background color.
*   **Do** embrace negative space. The midnight blue `background` is a design element in itself.
*   **Do** use `secondary` (#00e3fd) exclusively for "System" and "Security" status (Offline-first indicators, data encryption cues).

### Don'ts:
*   **Don't** use standard Material Design "Drop Shadows." They break the stealth-tech aesthetic.
*   **Don't** use 1px solid dividers between list items. Use 12px of `surface` color spacing instead.
*   **Don't** use pure white for body text. Always use `on-surface` (#f7f5fd) to reduce eye strain in low-light gym environments.