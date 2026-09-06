# Bindful — Development Plan
**Author:** Prisha Patel
**Date:** September 2026
**Status:** Core app built (camera, AI scan, results, impact tracking) → Polish before publishing

---

## Current State

The app is functionally complete:
- `ContentView` — home screen with navigation to Camera, My Impact, How It Works
- `CameraView` — live camera feed, capture, downscales photo before sending
- `AIService` — sends photo to the `bindful-api` backend, gets back one or more classified items
- `MultiResultView` — shows results (recycle/compost/trash, reason, tip) for everything found in the photo, saves each to history
- `ScanStore` — local scan history, streak tracking
- `ImpactView` — stats screen (items diverted, streak, recent scans)
- `HowItWorksView` — educational guide

**Not in scope:** photo upload / gallery picker. Camera-only.

Everything from here is polish before publishing, not new features.

---

## Remaining Work

### Testing Pass
- [ ] Bright outdoor light (park, direct sun)
- [ ] Indoor kitchen lighting (typical use case)
- [ ] Low light / evening
- [ ] Reflective surfaces (glass bottles, foil)
- [ ] Crumpled / dirty items (greasy pizza box test)
- [ ] Multiple items in frame — does `classifyMultiple` pick them all up correctly?
- [ ] Camera permission denied flow — currently no explicit handling, just relies on the OS prompt
- [ ] Confirm `bindful-api` privacy page and endpoint are both stable before submission

### Accessibility
- [ ] VoiceOver labels on camera shutter, result cards, nav buttons
- [ ] Dynamic Type check on result/impact screens
- [ ] High contrast check on category colors

### App Store Prep
- [ ] App icon
- [ ] Screenshots: home screen, camera viewfinder, multi-result screen (each category), impact screen, how-it-works
- [ ] App Store description + privacy nutrition label (matches `README.md` privacy section)
- [ ] Decide: public or keep GitHub repo private after submission

---

## Open Questions
- [ ] Is Fremont/California-specific (SB 1383) advice in scope long-term, or should it become location-aware?
- [ ] Should scan history ever sync (iCloud), or stay on-device only forever?
