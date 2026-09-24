# Sole Prop Prototype (iOS)

SwiftUI prototype, iOS 17+, iPhone only. Mock/local data — no backend integration yet.

## Setup

The Xcode project is generated from `project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen) and is not committed to git.

```bash
brew install xcodegen   # if not already installed
xcodegen generate
open SoleProp.xcodeproj
```

Re-run `xcodegen generate` any time `project.yml` changes or new files are added under `SoleProp/`.

## Structure

- `App/` — entry point, root navigation, router
- `DesignSystem/` — tokens (color, spacing, type, radius) pulled from Figma/BUI
- `Features/` — one folder per screen/flow
- `Models/` — data types
- `Mocks/` — sample/mock data for prototyping without a backend
