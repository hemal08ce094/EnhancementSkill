# Notices

ImpeccableSwiftUI is a derivative work of **Impeccable** by Paul Bakaus
(https://github.com/pbakaus/impeccable), licensed under the Apache License 2.0.
The skill text under `skill/impeccable-swiftui/` was rewritten from Impeccable's skill
(snapshot in `upstream/`, commit recorded in `upstream/SOURCE`) to target SwiftUI and
Apple platforms instead of web frontends. The detector under
`skill/impeccable-swiftui/scripts/detector/` is new code written for this port; it does
not contain code from Impeccable's Rust engine.

Changes from upstream: all command playbooks re-grounded in SwiftUI, Xcode and the
Apple Human Interface Guidelines; web-only features (live browser mode, generate,
doctor, the browser extension, the web detector) removed; platform references for
iOS, iPadOS, macOS, watchOS and visionOS added; a Swift detector with SwiftUI rules added.

Impeccable itself credits ehmo's platform-design-skills (MIT) for its iOS platform
reference; see `upstream/NOTICE.md`.

This project is not affiliated with or endorsed by Paul Bakaus.
