# Bindful

Bindful is an iOS app that tells you how to dispose of something. Point your camera at an item, and it tells you whether it's recycling, compost, or trash, along with a short reason why.

## Why I built this

Most people want to sort their waste correctly but don't actually know the rules, and getting it wrong (like tossing a greasy pizza box in recycling) can contaminate an entire batch. Bindful skips the guessing: scan the item, get an answer.

## How it works

1. Point your camera at the item you want to throw away
2. The photo is sent to Claude (Anthropic's AI) through a backend server I built
3. The AI identifies the item and classifies it as recycle, compost, or trash, based on California's SB 1383 waste rules
4. You get the category, a short reason, and a disposal tip
5. Every scan saves to your history, so you can track your streak and how much you've kept out of the landfill

## Privacy

- Photos are never stored, by the app or the server. They're used once to generate a result, then discarded.
- No account or sign-up required.
- Scan history is saved locally on your device only.
- Basic anonymous usage stats (like total scans) are tracked with a random device ID, never tied to your identity.

Full privacy policy: https://bindful-api.vercel.app/privacy.html

## Built with

**App (this repo)**
- Swift, SwiftUI
- AVFoundation for the camera
- No third-party libraries

**Backend** (separate repo)
- Vercel serverless functions (TypeScript)
- Claude Haiku 4.5 for image classification
- Redis for anonymous usage stats

The backend exists so the AI API key never has to live inside the app itself. The app only ever talks to my own server, and the server holds the real key.

## Files

```
Bindful/
  BindfulApp.swift        app entry point
  ContentView.swift       home screen
  CameraView.swift        camera capture, sends photo to backend
  AIService.swift         talks to my backend
  MultiResultView.swift   scan results screen
  HowItWorksView.swift    how-it-works page
  ImpactView.swift        personal stats screen
  ScanStore.swift         saves scan history locally
  ScanRecord.swift        scan data model
```

## AI assistance

Swift and SwiftUI were new to me going into this project, I'd mostly worked in Python before. I used Claude to help me learn the language, write and debug the Swift code, and figure out the backend architecture. I didn't build every part of this entirely on my own, and I want to be upfront about that.
