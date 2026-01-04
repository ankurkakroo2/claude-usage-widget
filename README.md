# Claude Usage Widget (macOS) — *paused / incomplete*

This was intended to be a native macOS menu-bar + WidgetKit experience that shows Claude usage/credits (session + weekly limits, prepaid balance) with an auto-refreshing desktop widget. The project is currently **on pause and incomplete**.

## Current state
- Builds successfully on macOS (Xcode 15+/Swift 5.9, macOS 14+ target).
- Auto-detects Claude session via browser cookies (SweetCookieKit) and fetches usage/credits when the app runs.
- App Group + widget entitlements are set, but data/rendering still need validation and polish.
- Menu bar icon may not appear reliably; runtime behavior is not verified end-to-end.

## How to run (developer)
1) Open `ClaudeUsageWidget.xcodeproj` in Xcode.
2) For both targets (`ClaudeUsageWidget`, `ClaudeWidget`): set your Team and enable App Groups → `group.com.claude.usagewidget`.
3) Build and run the `ClaudeUsageWidget` scheme. Allow cookie/keychain prompts so the app can read your Claude session.
4) Add the widget from the macOS widget picker; if blank, re-add after a manual refresh from the app.

## What’s inside (high level)
- `ClaudeUsageWidget` (app): menu bar host, refresh loop, auto cookie/org detection, Keychain + App Group storage.
- `ClaudeWidget` (WidgetKit extension): reads cached snapshot from App Group and renders small/medium/large layouts.
- `Shared`: models (`UsageData`, `BillingData`, `WidgetSnapshot`), storage (`StorageService`), API client (`ClaudeAPIService`), keychain helper.
- `BrowserCookieService`: auto-fetches `sessionKey` from installed browsers via SweetCookieKit.

## Known gaps / to finish
- Verify menu bar icon lifecycle and widget data updates on real accounts.
- Improve error handling and user feedback when auto-detect fails.
- Refine widget visuals to match the intended native glass aesthetic.
- Harden signing/profile settings for distribution (currently dev/local only).

## License
No explicit license has been declared; treat as closed/private unless specified otherwise.
