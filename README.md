# Baby First Words

iOS MVP (SwiftUI, iOS 17+) teaching first vocabulary to 1-2yo toddlers via repeated image + audio exposure, in English and Spanish. See `.claude/plans` or the PRD shared with the project owner for full product context.

## Requirements

- Xcode 16+ / iOS 17+ simulator or device
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) — the `.xcodeproj` is generated, not checked in by hand

## Setup

```bash
xcodegen generate
open BabyFirstWords.xcodeproj
```

Or build from the command line:

```bash
xcodebuild -project BabyFirstWords.xcodeproj -scheme BabyFirstWords \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Re-run `xcodegen generate` any time `project.yml` changes or new source files are added (xcodegen scans folders, so new files under `BabyFirstWords/` need a regenerate to show up in the project).

## Content & asset schema

All lesson content lives in [`BabyFirstWords/Resources/lessons.json`](BabyFirstWords/Resources/lessons.json):

```json
{
  "lesson_id": "animals",
  "en_name": "Animals",
  "es_name": "Animales",
  "icon": "pawprint.fill",
  "words": [
    { "word_id": "dog", "en_text": "Dog", "es_text": "Perro" }
  ]
}
```

For each `word_id` the app expects:
- An image named `<word_id>` in `BabyFirstWords/Assets.xcassets/<word_id>.imageset/`
- `BabyFirstWords/Resources/Audio/en/<word_id>.m4a`
- `BabyFirstWords/Resources/Audio/es/<word_id>.m4a`

**Everything currently in the repo is placeholder** (see [`NOTICE.md`](NOTICE.md)) — swap files at the same paths with real photos/recordings, no code changes needed. To add a new word: add an entry to `lessons.json`, drop in an image and two audio files at the paths above, then `xcodegen generate` again.

### Regenerating placeholders

```bash
./Scripts/generate_placeholder_audio.sh    # macOS `say` TTS -> Resources/Audio/{en,es}
swift Scripts/generate_placeholder_images.swift .   # emoji cards -> Assets.xcassets
```

## Architecture

- `Models/` — `Word`, `Lesson`, `LessonCatalog` (decodes `lessons.json` from the bundle)
- `Services/` — `AppSettings` (`@Observable`, UserDefaults-backed: language, volume, opened lessons), `AudioPlayer` (AVAudioPlayer wrapper)
- `Views/` — `HomeView` (lesson picker), `LessonPlayerView` (tap/swipe-to-hear word cards), `ParentalGateView` (math-question gate), `SettingsView` (language toggle, volume, progress)

No backend, no third-party dependencies, fully offline.
