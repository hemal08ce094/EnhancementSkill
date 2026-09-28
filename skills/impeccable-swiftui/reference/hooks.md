# /impeccable-swiftui hooks

Manage the **design detector hook** for the current project.

The hook is a Claude Code `PostToolUse` hook. After every Edit, Write, or MultiEdit it pipes the hook JSON to `scripts/impeccable-swiftui hook`, which scans the edited file if it is a `.swift` file and returns any findings as `additionalContext`, so they land in your context right after the edit. Every other file type is a silent no-op. It never blocks an edit; it reports.

Every hook is a mechanical pass. The reflexes no scanner catches live in [craft-floor.md](craft-floor.md), which the skill loads before it edits UI, so they apply whether or not the hook is wired. Without the hook, run `scripts/impeccable-swiftui detect <touched files>` once before handing off.

There is no `hooks` verb in the binary. You perform every action below yourself with file tools, touching only the keys named here and preserving everything else in each file. Two files are involved:

- `.claude/settings.local.json` in the project root: where the hook is wired. Machine-local; Claude Code keeps it out of git. Check `.gitignore` covers it and say so if it doesn't.
- `.impeccable/config.json`: shared detector config, committed. `detector.ignoreRules` (rule ids) and `detector.ignoreFiles` (globs relative to the project root). `.impeccable/config.local.json` has the same shape for private, per-developer exceptions.

`<skill-dir>` below is the **absolute** path of the directory containing SKILL.md. Resolve symlinks; the hook runs from a fresh shell and a relative or `~` path breaks silently.

## Routing

The first argument is the action. Defaults to `status`.

| Action | What it does |
|---|---|
| `status` | Report whether the hook is wired, the command it runs, and the ignored rules and files from both config files. |
| `on` | Add the hook entry to `.claude/settings.local.json`, then warm the detector build. |
| `off` | Remove the hook entry; leave every other hook alone. |
| `ignore-rule <id>` | Append `<id>` to `detector.ignoreRules`. Suppresses the rule project-wide. |
| `ignore-file <glob>` | Append `<glob>` to `detector.ignoreFiles`. Suppresses **every** rule for matching files. |

Add `--local` to either ignore action only when the user explicitly asks for a private exception; it writes `.impeccable/config.local.json` instead.

## Flow

### on

1. Read `.claude/settings.local.json` if it exists; otherwise start from `{}`. If it exists but is not valid JSON, stop and tell the user; never overwrite it.
2. If `hooks.PostToolUse` already holds an entry whose command ends in `impeccable-swiftui" hook`, update that command's path if it changed and stop there (idempotent). Otherwise append this entry to `hooks.PostToolUse`, creating the keys as needed and keeping every existing hook, matcher, and top-level key:

   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Edit|Write|MultiEdit",
           "hooks": [
             {
               "type": "command",
               "command": "\"<skill-dir>/scripts/impeccable-swiftui\" hook",
               "timeout": 60
             }
           ]
         }
       ]
     }
   }
   ```

   Keep the inner quotes: skill paths often contain spaces.
3. Warm the build so the first hook doesn't time out compiling: run `"<skill-dir>/scripts/impeccable-swiftui" rules` once and confirm it lists rules.
4. Reply: "Done. The design hook will fire after the next Edit/Write on a Swift file." Claude Code picks up settings changes on the next tool call; if it doesn't, the user can open `/hooks` to reload.

### off

Remove only the hook object(s) whose command ends in `impeccable-swiftui" hook`. Drop a `PostToolUse` entry left with an empty `hooks` array, and an empty `PostToolUse` array; leave everything else untouched. Reply: "Done. New edits will not trigger the design hook in this project until you run `/impeccable-swiftui hooks on`."

### status

Report, tersely: wired or not (and the exact command if wired, flagging a path that no longer exists); `ignoreRules` and `ignoreFiles` from `.impeccable/config.json` and `.impeccable/config.local.json`, labeled by file; unreadable or malformed config files, labeled as ignored. No commentary unless asked.

### ignore-rule, ignore-file

Validate a rule id against `scripts/impeccable-swiftui rules --json` before writing it. Create `.impeccable/config.json` as `{ "detector": { "ignoreRules": [], "ignoreFiles": [] } }` if missing; append without duplicating; keep every other key (`buildPath` and anything else) as it was. Print the resulting `detector` block.

## Triage findings

The hook never writes ignores. Triage each finding into one of three outcomes:

- **Real design problem:** fix it. Never add a waiver to skip a fix.
- **Confident false positive or sanctioned exception:** waive it at the narrowest scope yourself and disclose it in your reply. The bar is evidence you can name: a token file the detector didn't recognize, a debug-only or preview-only view, literal motion (a ball that bounces), or a choice the user already confirmed. Write the evidence into the waiver's reason as `<who decided>: <evidence>`; write "user confirmed" only when the user actually did.
- **Unsure:** leave the finding standing and ask the user in one line. Ask once; a one-line question costs less than the hook re-firing on every later edit.

Narrowest first:

1. `// impeccable-disable-next-line <rule>: <reason>` above the line (or `// impeccable-disable-line <rule>: <reason>` at its end). Self-serve.
2. `// impeccable-disable <rule>: <reason>` at the top of the file, when one rule is legitimately everywhere in that file (a `Theme.swift`-style token file with an unusual name, a shader demo). Self-serve, disclosed.
3. `ignore-file <glob>`: only for files out of design review entirely (generated code, snapshot fixtures, deliberate anti-pattern samples). It silences every rule, including future ones. Ask first.
4. `ignore-rule <id>`: only when the user asks to drop that rule project-wide. Ask first.

Examples:

```swift
// impeccable-disable-next-line bounce-easing: agent: literal ball-bounce, the bounce is the subject
.animation(.spring(duration: 0.6, bounce: 0.5), value: dropped)
```

```swift
// impeccable-disable hardcoded-color: user confirmed: BrandSwatches.swift is the palette source
```

## Constraints

- Never edit the launcher or the detector sources from this flow; they are skill plumbing.
- Never touch hooks you didn't install, even ones that look similar.
- `detect --no-config` bypasses `.impeccable/config.json`; use it to see what an ignore is hiding.
- If the user asks to "disable the hook" globally, lead with `/impeccable-swiftui hooks off` (persistent for this project).
