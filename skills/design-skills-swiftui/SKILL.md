---
name: design-skills-swiftui
description: Pick and apply one of 67 ready-made design systems (neobrutalism, glassmorphism, claymorphism, neumorphism, material, shadcn, matrix, riso, terracotta, retro arcade and more) to an iOS, iPadOS, macOS, watchOS, tvOS or visionOS SwiftUI app using the DesignSkills package (github.com/hemal08ce094/DesignSkillsSwiftUI), the SwiftUI port of bergside/awesome-design-skills. Use when the user asks to give a SwiftUI app a style or design system, restyle or theme screens, make an app look like a named aesthetic, compare design styles, or apply an awesome-design-skills / typeui.sh skill in Swift.
license: MIT
metadata:
  author: hemal08ce094
  package: https://github.com/hemal08ce094/DesignSkillsSwiftUI
---

# Apply a DesignSkills style to a SwiftUI app

`DesignSkills` is a Swift package with 67 complete themes (palette for light and dark, typography with Dynamic Type, spacing, radii, surface recipes, press motion) and themed components. Every theme also has a full per-style skill in the repo at `skills/<slug>/SKILL.md` with tokens, surface recipes, component rules and a QA checklist.

Package: `https://github.com/hemal08ce094/DesignSkillsSwiftUI`, product `DesignSkills`, from `0.1.0`. Needs iOS 17, macOS 14, tvOS 17, watchOS 10 or visionOS 1. No dependencies.

## 1. Choose the style

- If the user named a style, map it to a slug from `references/styles.md` ("brutalist" → `brutalism` or `neobrutalism`; "glass"/"liquid glass" → `glassmorphism`; "soft UI" → `neumorphism`; "Apple-like" → `premium`; "terminal"/"hacker" → `matrix`).
- If they described a mood, shortlist two or three from `references/styles.md` and say why; pick one unless they want to choose.
- Then **read that style's own skill** (`skills/<slug>/SKILL.md` in the repo, or fetch it from GitHub) before editing. It has the exact tokens, the surface recipes that make the style recognisable, and its do/don't rules. Follow it over anything generic here.

## 2. Preflight

- Check the app's deployment targets against the minimums above; if lower, stop and ask, or use the style skill's standalone recipe instead of the package.
- Decide scope from the request. "Style the onboarding" means onboarding only.
- Find existing styling to replace: `grep -rn "Color(\|\.font(\|\.cornerRadius\|\.shadow(\|RoundedRectangle\|buttonStyle" --include=*.swift`, and read each call site first.

## 3. Add the package

Xcode: File ▸ Add Package Dependencies ▸ `https://github.com/hemal08ce094/DesignSkillsSwiftUI` ▸ Up to Next Major from `0.1.0` ▸ add `DesignSkills` to the app target. `Package.swift`:

```swift
.package(url: "https://github.com/hemal08ce094/DesignSkillsSwiftUI", from: "0.1.0"),
// target dependency
.product(name: "DesignSkills", package: "DesignSkillsSwiftUI"),
```

Build once before converting anything.

## 4. API

```swift
import DesignSkills

ContentView().designTheme(.neobrutalism)   // root, once; forces the scheme for dark-only / light-only styles
DesignTheme.named("riso")                   // look up by slug; DesignTheme.all lists all 67

.themedBackground()                         // page background, edge to edge
.themedFont(.display | .title | .headline | .body | .callout | .caption | .label | .mono)   // Dynamic Type scaled
.themedForeground(.text | .textMuted | .primary | …)
.themedSurface(\.card)                      // any surface recipe: background, card, buttonPrimary, buttonSecondary, field, chip

Button("Save") {}.buttonStyle(.themed(.primary))      // .secondary, .ghost, .destructive; fullWidth: true
ThemedCard { … }                                      // padding: optional
ThemedTextField("Email", text: $email, prompt: "you@example.com", message: nil, isError: false)
Toggle("Alerts", isOn: $on).toggleStyle(.themed)
ThemedBadge("Synced", tone: .success)                 // .neutral, .primary, .success, .warning, .danger
ThemedProgressBar(value: 0.4)
ThemedSectionHeader("Account")

@Environment(\.designTheme) var theme                 // raw tokens
theme.spacing.md; theme.radius.lg; theme.palette(for: colorScheme).primary.color
theme.dynamicColor(.primary)                          // Color that follows appearance by itself

DesignThemeShowcase()                                 // sample screen for a quick look
DesignThemeGallery()                                  // every theme with a picker, for a debug menu
```

## 5. Convert

- Theme the root once; remove per-view hex colors, fixed font sizes, ad-hoc corner radii and shadows in scope, and replace them with roles and components.
- Keep native structure: `NavigationStack`, `TabView`, `List`, sheets, toolbars. Restyle content, not navigation mechanics. For `List`, use `.scrollContentBackground(.hidden)` + `.themedBackground()` and rows styled with theme tokens.
- Fonts: themes name the upstream families (Inter, Space Mono, VT323…). If the user wants the exact faces, add the files to the target and list them under `UIAppFonts`; otherwise the system fallback design in the theme is used automatically.
- Keep every accessibility behavior the package provides: Dynamic Type, 44pt targets, Reduce Motion (no press motion), Reduce Transparency (glass → solid), Increase Contrast (thicker borders, muted text promoted).

## 6. Verify

- Build. Preview the converted screens in light, dark and at `.accessibility3` Dynamic Type.
- Walk the style skill's QA checklist.
- Report which screens changed and anything left unconverted.
