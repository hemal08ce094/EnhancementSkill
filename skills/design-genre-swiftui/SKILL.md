---
name: design-genre-swiftui
description: Give a native iOS, iPadOS, watchOS, macOS or visionOS app one design genre (Quiet, Character, Atmosphere, Data or Loud) and a written design language that every later screen follows. It names the genre from the app's job, applies that genre's rules, finds the one thing the category leaders all do the same way, and records the result in DESIGN.md. It also audits an existing app against its own genre and fixes only the places where it breaks the rules. Use when an app looks generic or "vibe-coded", when the user asks which design direction or genre an app should have, asks for a design language or DESIGN.md, wants an existing app checked for consistency, or says "pick a genre".
---

# Design genre for native apps

Method distilled from Builder Cult's public breakdown "the five design genres behind premium apps" (instagram.com/buildercult), recast for SwiftUI and extended with an audit procedure and a worked example. No third-party code, copy, screens or revenue figures are included.

Read `references/genres.md` to choose the genre, then copy `references/design-md-template.md` and fill every part before changing code.

## The idea

An app with no direction gets the average of every app: a gradient from the calm ones, emoji from the cute ones, stat cards from the dashboards, white space from the minimal ones. Colour is only the symptom. The cause is that the app never chose a point of view, and people judge that in the first glance, before they read a word.

Apps that feel designed chose one **genre** and obeyed its rules everywhere. The genre is not a style. It follows from what people come to the app to do:

| Genre | People come to | The screen is |
|---|---|---|
| Quiet | get something done | a calm tool |
| Character | return every day to something that needs them | a relationship |
| Atmosphere | step into a place | a room |
| Data | understand their own numbers | an instrument |
| Loud | express their taste | a stage for their content |

One genre leads. A second may ride inside it (an Atmosphere app that carries Data), and then the document says which one wins when they disagree.

## Where this sits among the other skills

- `enhancement-skill` answers who the app is for and how it should feel (the Touch Brief). Run that first on a new app.
- This skill answers which family of rules the app obeys. It writes `DESIGN.md`.
- `design-skills-swiftui` supplies a ready-made world when the genre needs one.
- `signature-moment-swiftui` specs the one moment the genre tells you to design hardest.
- `impeccable-swiftui` is the craft floor and the final audit.

## Procedure for a new app

1. **Name the job.** One sentence: what a person opens this app to do, and how often. Pick the genre from `references/genres.md`. If two fit, pick the one that matches the daily use, not the marketing.
2. **Look at who is winning.** Find the top apps in the category with whatever market data the session has (an App Store Optimisation tool, the store charts, the user's own list). Look at their real screens, not their marketing pages. Never invent revenue or download numbers; if there is no source, name the apps and leave the numbers out.
3. **Name their genre and pull the rules.** For the leaders, write down colours, type, spacing, corners, motion and how they talk. Most of a category shares one genre.
4. **Find the gap.** What does every one of them do the same way? That sameness is where this app can stand apart while staying inside the genre.
5. **Add the app's own material.** One colour with a meaning, one object or character nobody else has, one voice.
6. **Write `DESIGN.md`** from the template. From then on, read it before building any screen, and change it on purpose, never by drift.

## Procedure for an existing app (the audit)

Most shipped apps already have a genre and break it in a few places. Do not redesign. Find the breaks.

1. **Capture the current screens** from a running build: home, the main task, settings, onboarding, the paywall, one empty state, one error state. Capture before touching code so there is a before picture.
2. **Name the genre the app already is.** Read it off the screens, not the README.
3. **Check each screen against the genre's rules and the shared rules below.** Typical breaks, in the order they usually appear:
   - Two colours doing the same job (selected is gold on one screen and blue on another).
   - A hero number with no sentence saying what it means.
   - A marketing surface (paywall, onboarding) led by a generic symbol when the app owns a real object.
   - More than one primary button style.
   - An empty state that looks like loading, or an error with no way out.
   - Notifications titled with their category.
4. **Write `DESIGN.md` for the app as it should be,** then make the smallest set of changes that brings the app into line. Leave what already works.
5. **Capture the same screens again** and put before and after side by side. Say what was not checked.

## Rules every genre shares

- **One job per screen.** If a screen has two jobs, it is two screens or one of them is secondary.
- **One system.** One type family, one icon set, one spacing scale, one corner scale, used everywhere.
- **One meaning per colour.** Write the meaning next to the token. A colour that means "selected" is never decoration.
- **Motion that settles.** Things arrive, overshoot little or not at all, and rest. Every animated piece has a Reduce Motion form that holds its most informative frame.
- **Copy that sounds like a person.** Specific, short, in the app's voice. Lead with the fact, not the category.
- **Design the moments that get skipped:** the empty screen, the error, the win. These are where a generated app shows.

## Surfaces before screens

Many of the apps people pay for are barely opened. They do their job on the Lock Screen, the Home Screen and the Dynamic Island. For a feature that has a glanceable form, design in this order:

1. **Widget and Live Activity.** Two seconds and a few centimetres: one number, one action, readable at a glance. Treat the widget as the product and the app as its settings.
2. **Notification.** Specific, well timed and human. "Don't forget to log today" is a category. "You have been on it for 15 minutes" is a fact. A notification that sounds like a person is allowed to give up politely.
3. **The in-app screen.** Last.

On Apple platforms this means WidgetKit families (including accessory families for the Lock Screen and Watch), ActivityKit, App Intents for the one action, and `UNNotificationContent` with a real title. A notification is a screen: give it the same copy review as a screen.

## Native casting

- Genre rules are principles. Apple's Human Interface Guidelines and the project's own design system win where they conflict.
- Keep native navigation, lists, sheets and toolbars in every genre, Loud included. The genre changes the skin and the content, not how the platform works.
- Dark or light is a genre decision with a reason (Atmosphere apps for night use are dark). Where there is no reason, support both.
- Check every colour pair for contrast, including text on the accent fill.
- iPad and foldable windows are not a centred phone column. Say in `DESIGN.md` how the genre uses the extra space.

## Rules

- Copy the method, never another app's screens, copy, characters or brand. Leaders are evidence for the genre, not templates.
- Do not quote revenue, downloads or user counts without a source the user can check.
- One genre leads per app. Do not mix rule sets screen by screen.
- A mascot in the corner is decoration. In a Character app the character has a job, and the app stops working without it.
- An audit changes the fewest things that restore the rules. If the list grows past about ten changes, the app needs a redesign brief, not this skill.
- Report what was rendered and what was only read in code.

## Worked example

`references/genres.md` ends with a real audit: an AR plane-spotting app that was already Atmosphere carrying Data, and the six changes that brought it back to its own rules.
