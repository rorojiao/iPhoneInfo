# AGENTS.md (iPhoneInfo/App)

## Overview

App entry point, global state, and top-level navigation wiring.

## Where To Look

- `@main` app + shared state: `iPhoneInfo/App/iPhoneInfoApp.swift` (`iPhoneInfoApp`, `AppState`, `AppTab`)
- Root content / tab switching: `iPhoneInfo/App/ContentView.swift`

## Conventions (This Directory)

- `AppState` is an `ObservableObject` owned by the app via `@StateObject`.
- Views consume `AppState` via `@EnvironmentObject`.
- Keep `AppState` minimal: UI routing flags and cross-screen toggles only.

## Anti-Patterns

- Do not add “service orchestration” here; keep services owned/observed at the screen level unless the state is truly global.
- Do not mix benchmark execution logic into `ContentView`; it should route to dedicated views/services.
