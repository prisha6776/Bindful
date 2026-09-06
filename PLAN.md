# Bindful — Development Plan
**Author:** Prisha Patel
**Date:** March 2026
**Status:** Phase 1 (UI) complete → Planning Phase 2–4

---

## Current State

The app has a fully designed home screen with navigation to three destinations:
- `CameraView` — black screen placeholder
- `PhotoPickerView` — text placeholder
- `HowItWorksView` — fully built educational guide

Everything from here is new feature work.

---

## Phase 2: Camera & Permissions

### Goal
Replace `CameraView` placeholder with a real, live camera feed.

### Tasks

#### 2.1 — Request Camera Permission
- Add `NSCameraUsageDescription` key to `Info.plist`
  - Message: `"Bindful needs your camera to identify and sort waste items."`
- Use `AVCaptureDevice.requestAccess(for: .video)` to trigger the system permission dialog
- Handle three states:
  - **Granted** → start the camera session
  - **Denied** → show an in-app message with a deep link to Settings
  - **Not determined** → show a pre-permission explanation screen before asking

#### 2.2 — Live Camera Feed
- Use `AVCaptureSession` + `AVCaptureVideoPreviewLayer` wrapped in a `UIViewRepresentable` for SwiftUI
- Lock orientation to portrait
- Set session quality preset to `.photo` (highest still image quality)
- Display viewfinder full-screen, edge-to-edge (same approach as home screen background)

#### 2.3 — Capture Button Behavior
- When user taps the white shutter button:
  1. Freeze the frame (overlay the last captured frame as a still image)
  2. Show a subtle flash animation (white overlay fading from opacity 0.8 → 0)
  3. Trigger the AI pipeline (Phase 3)
  - ~~Shutter sound~~ — removed, disruptive to users
- Use `AVCapturePhotoOutput` to capture a high-res still

#### 2.4 — Camera UI Layer
- Overlay on top of camera feed:
  - A center targeting reticle (rounded square outline) to guide framing
  - A bottom bar with the capture button
  - A top bar with a back button and a small Bindful logo
  - Subtle label: "Point at an item to scan"

---

## Phase 3: AI Recognition

### Goal
Send the captured image to an AI model, classify the waste item, and handle low-confidence results.

### Tasks

#### 3.1 — Choose AI Approach

Two options, pick one based on constraints:

| Option | How | Pros | Cons |
|--------|-----|------|------|
| **On-device (CoreML)** | Train/download a `.mlmodel`, run locally | Works offline, fast, private | Limited accuracy, needs training data |
| **Cloud API (Claude / GPT-4V)** | Send image to Anthropic or OpenAI API | High accuracy, zero training needed | Requires internet, API cost |

**Recommended:** Start with Claude API (vision) for accuracy. Add CoreML fallback later if offline support is needed.

#### 3.2 — Build the AI Request
- Compress image to JPEG, max 1MB before sending
- Construct a structured prompt:
  ```
  You are a waste sorting assistant. Analyze this image and identify the primary item.
  Respond ONLY in this JSON format:
  {
    "item": "plastic water bottle",
    "category": "RECYCLE",
    "confidence": 0.95,
    "reason": "Plastic #1 (PET) is accepted in most curbside recycling bins.",
    "tip": "Remove the cap and rinse before recycling."
  }
  category must be one of: RECYCLE, COMPOST, TRASH
  confidence is 0.0–1.0
  If you cannot identify the item clearly, set confidence below 0.6 and explain in reason.
  ```
- Parse JSON response into a Swift `WasteResult` struct:
  ```swift
  struct WasteResult: Codable {
      let item: String
      let category: WasteCategory   // enum: .recycle, .compost, .trash
      let confidence: Double
      let reason: String
      let tip: String
  }
  ```

#### 3.3 — Confidence Gating
- If `confidence >= 0.75` → proceed to Result Screen
- If `confidence < 0.75` → do NOT show a result. Instead:
  - Unfreeze the camera
  - Show a non-blocking toast: "Move closer for a better look"
  - Log the low-confidence attempt (for future model improvement)

#### 3.4 — Loading State
- While waiting for AI response, show:
  - Frozen captured frame in background
  - Centered animated spinner with label "Analyzing..."
  - Subtle pulsing animation on the targeting reticle

#### 3.5 — Error Handling
- No internet → "No connection. Try uploading a photo instead."
- API error / timeout → "Something went wrong. Tap to retry."
- Unrecognizable image → handled by confidence gate (3.3)

---

## Phase 4: Result Screen

### Goal
Show a clear, confident answer after a successful scan.

### Tasks

#### 4.1 — Result Screen Layout
Full-screen sheet that slides up from the bottom after scan completes.

**Top section — Category Banner:**
- Large bold text: `RECYCLE`, `COMPOST`, or `TRASH`
- Full-width color background:
  - RECYCLE → Blue (`#2196F3`)
  - COMPOST → Green (`#4CAF50`)
  - TRASH → Gray (`#9E9E9E`)
- Icon: a matching SF Symbol (arrow.3.trianglepath.circle / leaf.circle / trash.circle)

**Middle section:**
- Thumbnail of the captured photo (small, rounded)
- Item name: `"Plastic Water Bottle"`
- Reason text: `"Plastic #1 (PET) is accepted in most curbside recycling bins."`
- Tip text in a subtle card: `"Remove cap and rinse before recycling."`

**Bottom section — Feedback:**
- Prompt: "Did we get it right?"
- Two buttons: `Yes, correct` / `No, fix it`
- If "No" tapped → show a 3-option picker (Recycle / Compost / Trash) to collect the correct label
- Log both the image hash and the correction locally (for future model fine-tuning)

#### 4.2 — Actions After Result
- **Scan Again** button → dismiss sheet, unfreeze camera
- **Share** button → system share sheet with a summary card image

#### 4.3 — Result Data Model
```swift
// Store locally for history / feedback
struct ScanRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let itemName: String
    let category: WasteCategory
    let confidence: Double
    let userCorrection: WasteCategory?  // nil if user confirmed correct
}
```

---

## Phase 5: Photo Upload Flow

### Goal
Build out `PhotoPickerView` to mirror the camera flow but using a photo from the gallery.

### Tasks
- Use `PhotosUI.PhotosPicker` (iOS 16+ native, no permission dialog needed)
- After image selected → run the same AI pipeline from Phase 3
- Show the same Result Screen from Phase 4
- Add `NSPhotoLibraryUsageDescription` to `Info.plist` only if saving to library is added later

---

## Phase 6: Polish & Testing

### Goal
Ensure the app is fast, clear, and works in real-world conditions.

#### 6.1 — User Flow Audit
Walk through as a first-time user:
- [ ] Is it clear what the app does from the home screen?
- [ ] Is the camera viewfinder framing obvious?
- [ ] Is the result legible in 2 seconds or less?
- [ ] Is there a clear path back to scanning after a result?

#### 6.2 — Real-World Testing Checklist
- [ ] Bright outdoor light (park, direct sun)
- [ ] Indoor kitchen lighting (typical use case)
- [ ] Low light / evening
- [ ] Reflective surfaces (glass bottles, foil)
- [ ] Crumpled / dirty items (greasy pizza box test)
- [ ] Multiple items in frame — does it pick the right one?

#### 6.3 — Performance Targets
| Metric | Target |
|--------|--------|
| Time to camera ready | < 1.5s |
| AI response time | < 3s on good connection |
| Result screen render | < 0.3s after response |
| App launch to home | < 1s |

#### 6.4 — Accessibility
- VoiceOver labels on all buttons and result text
- Dynamic Type support for result screen text
- High contrast mode check

---

## Phase 7: Documentation & Presentation

#### 7.1 — Technical Specs Doc
- Architecture diagram (SwiftUI View tree + AI pipeline)
- API usage and cost estimate
- Privacy policy draft (what data is sent/stored)
- Supported devices and OS versions

#### 7.2 — Screenshots for App Store / Presentation
Required screens:
1. Home screen
2. Camera viewfinder (in use)
3. Result screen — RECYCLE
4. Result screen — COMPOST
5. Result screen — TRASH
6. How It Works guide

#### 7.3 — Demo Script (2-minute walkthrough)
1. Open app → explain home screen design
2. Tap Scan → point at a plastic bottle → show result
3. Tap "No, fix it" → show feedback flow
4. Navigate to How It Works → show educational content
5. Explain AI confidence gating and why it matters

---

## Build Order Summary

```
Phase 2  →  Phase 3  →  Phase 4  →  Phase 5  →  Phase 6  →  Phase 7
Camera      AI Core     Results     Upload       Polish       Docs
~3 days     ~4 days     ~2 days     ~1 day       ~2 days      ~1 day
```

Dependencies:
- Phase 4 depends on Phase 3 (needs `WasteResult` struct)
- Phase 5 reuses Phase 3 + 4 (same pipeline, different input)
- Phase 6 + 7 happen after all features are stable

---

## Open Questions

- [ ] Which AI API to use — Claude (Anthropic) or GPT-4V (OpenAI)?
- [ ] Should scan history be stored on-device only, or synced via iCloud?
- [ ] Is Fremont-specific recycling advice in scope, or should it be generic?
- [ ] Is App Store submission a goal, or is this for demo/presentation only?
