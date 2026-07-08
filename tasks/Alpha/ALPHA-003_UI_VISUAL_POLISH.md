# Task ID

`ALPHA-003`

# Task Name

Core UI/UX Visual Polish & Screen Transitions

# Owner

UI/UX Artist / Frontend Developer

# Status

Current Status: Not Started

# Priority

Current Priority: P1

# Goal

Elevate the UI from a functional/debug level to a polished, premium aesthetic. This task focuses on polishing layouts, card designs, progress bars, loading states, error states, and implementing smooth transition animations.

# Scope

- [ ] Complete the UI Polish checklist categorized below:

### Visual Polish
- [ ] **Monster Card**: Full visual card layouts including stats and elemental labels.
- [ ] **Borders**: Premium rarity borders (Common, Rare, Legendary) and selection outlines.
- [ ] **Icons**: Custom/unified assets for items, skills, and currencies.
- [ ] **Typography**: Consistent modern type scaling (e.g. font size hierarchy, no fallback fonts).
- [ ] **Color System**: Curated color palette (hex/RGB tokens) instead of browser default colors.

### UX Polish
- [ ] **Loading**: Fullscreen loading screens and inline spinners.
- [ ] **Toast**: Toast notification alerts sliding in when receiving rewards or completing achievements.
- [ ] **Tooltip**: Detailed hovering tooltips showing creature or item stats.
- [ ] **Confirmation**: Confirmation dialog modals before critical resource spending.
- [ ] **Disabled button**: Blocked input visual states when requests are processing.
- [ ] **Empty state**: Clean placeholders shown when inventories or collections are empty.
- [ ] **Error state**: Banners or toasts clearly showing server rejection codes.

### Technical UI Polish
- [ ] **Responsive**: Dynamic scaling across mobile, tablet, and widescreen PC ratios.
- [ ] **Safe Area**: Adherence to device notch margins and safe zone layouts.
- [ ] **Animation**: Screen transition animations (e.g. fade, slide, or zoom) on routing.
- [ ] **No layout overflow**: Ensuring labels and frames do not overlap.
- [ ] **No clipped text**: Proper TextWrapped properties and size bounds.

# Out of Scope

- [ ] 3D models or particle VFX (handled in ALPHA-004).

# Required Reading

- [ ] `docs/README.md`
- [ ] `Jarvis_Genesis/.DaoGang/Jarvis.md`

# Dependencies

- [ ] UI controllers and views from core MVP modules must be functional.

# Deliverables

- [ ] Updated UI View scripts under `src/client/views/`.
- [ ] UI stylesheet/theme configuration updates.

# Implementation Rules

- Do not use TailwindCSS unless explicitly confirmed.
- Avoid browser defaults; use premium theme tokens.
- Keep layout logic responsive.

# Testing Checklist

- [ ] Verify UI layouts on phone, tablet, and PC screen ratios.
- [ ] Verify transition animations do not cause script delay or yield errors.
- [ ] Verify error states and loading overlays block interaction when active.
- [ ] Check for text clipping on extremely small screen dimensions (e.g. mobile portrait).

# Review Checklist

- [ ] Visual design meets high-fidelity production standard.
- [ ] No layout clipping or text overlap.

# Definition of Done

- [ ] All scoped deliverables are complete.
- [ ] Mobile/PC layout responsive checks pass.
- [ ] Reviewer approval is recorded.

# Handoff Notes

- Files changed:
- Folders changed:
- Validation performed:
- Validation not performed:
- Known risks:
- Follow-up tasks:

# Suggested Future Improvements

- None.
