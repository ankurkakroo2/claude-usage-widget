# Claude Usage Widget — Technical & Visual Design (paused)

Status: project is **paused/incomplete**. This doc captures the intended design and current implementation snapshot.

## Goals
- Native macOS menu bar app + WidgetKit extension.
- Automatically surface Claude usage (5h/7d limits) and prepaid credits with minimal user input.
- Clean, native “glass” aesthetic for widgets and menu surfaces.

## Architecture
- Targets: `ClaudeUsageWidget` (app), `ClaudeWidget` (WidgetKit), `Shared` (framework).
- App Group: `group.com.claude.usagewidget` for shared UserDefaults snapshot.
- Sandboxing: both app and widget are sandboxed; App Group enabled.
- Key components:
  - `ClaudeAPIService`: fetch usage (`/organizations/{id}/usage`) and credits (`/organizations/{id}/prepaid/credits`).
  - `BrowserCookieService`: auto-detect `sessionKey` via SweetCookieKit (reads browser cookies).
  - `MenuBarController`: menu host, refresh timer, snapshot writer, widget reloads.
  - `StorageService`: caches `WidgetSnapshot` in App Group.
  - `ClaudeWidgetProvider`: reads snapshot and supplies timelines to WidgetKit.
  - `ClaudeWidgetViews`: small/medium/large layouts with glass-style cards.

## Data flow (intended)
1) App launches → auto-detect `sessionKey` via SweetCookieKit → fetch org id → call usage/credits APIs.
2) Build `WidgetSnapshot` and write to App Group.
3) Trigger `WidgetCenter.reloadAllTimelines()`.
4) Widget reads the snapshot and renders metrics.

## UI/Visual notes
- Use system materials (`.regularMaterial`) and SF Rounded for a native, glassy feel.
- Small: header + session/weekly progress.
- Medium: header + session/weekly + credits line.
- Large: session/weekly with reset times, credits, status row.

## Open issues / gaps
- Menu bar icon reliability not confirmed on all machines.
- Widget transparency/design needs final polish.
- Error surfacing for failed auto-detect or API errors is minimal.
- Signing/provisioning is developer-only; no distribution setup.

## Build/Run (dev)
1) Open in Xcode; set Team for both targets; enable App Groups (`group.com.claude.usagewidget`).
2) Build `ClaudeUsageWidget`; allow cookie/keychain prompts.
3) Add the widget; if blank, remove/re-add after forcing a refresh from the app.

## References / dependencies
- SweetCookieKit (browser cookie access).
- URLSession (API calls), Keychain (secrets), WidgetKit/SwiftUI (UI).

## License
Not declared; treat as private/internal unless specified otherwise.
