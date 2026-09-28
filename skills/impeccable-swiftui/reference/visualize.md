# Visualize: screen comps, region map, asset production

Load this from [new-work.md](new-work.md) on a comp-led build, and only when an image-generation tool is available in this session (a harness-native image tool or an image-generation MCP server). A code-led build skips this file by design, not by drift. PRODUCT.md and the direction contract in the surface brief are preconditions. New-work has already resolved the visual world; this file must not reopen it. When new-work's structure round already put three comps before the user and one was locked, this round is discharged: record that comp as approved and continue at [After approval](#after-approval-the-comp-becomes-a-spec).

A comp tests composition, hierarchy, density, focal moment, signature use, and image requirements. It is not a second identity workshop: palette, type direction, material language, component character, symbol treatment, and motion grammar stay fixed.

## Generate three compositional options

Render three distinct, high-fidelity, full-screen app mocks of the requested screen, saved as `.impeccable/mocks/<surface>/comp-1.png`, `comp-2.png`, `comp-3.png`, each with a sidecar `comp-N.json` holding the exact prompt, the tool, the reference image used, and the pixel size. Comps are the build thread's own work, never delegated: the thread that writes the prompts holds the direction's context and has seen every comp when the build starts.

**Frame at the device, flat.** The frame is the screen itself at the primary device's native resolution: 1206×2622 portrait for a 6.3-inch iPhone, 2064×2752 portrait for a 13-inch iPad, a Mac window at its default content size, landscape. No bezel, no hand, no desk, no perspective mockup, no floating second phone: a comp is a screenshot that does not exist yet, and the region map needs its pixels to be the screen's pixels. When the tool cannot reach the device aspect, generate at its tallest portrait aspect (9:16 or taller), say so in the sidecar, and measure every box in normalized coordinates so the map survives the difference. A phone screen comped landscape misstates the composition before anything is built.

**The chosen card's decision comp is option one.** It already renders this direction at full fidelity; generate two more that vary what it held fixed. Only a round arriving with no decision comp renders all three here. Three is the number: one invites rubber-stamping; the spread between three surfaces the composition worth building.

**On an established world, anchor on pixels.** Capture a representative existing screen in the Simulator and pass it as the reference image. The prompt leads with the new screen's structure while the reference carries palette, type, symbol treatment, and component character; DESIGN.md's words alone drift where a pixel reference does not. Name what the reference contributes and what it must not: its content, its specific cards and banners, stay behind.

Prompt and self-check discipline:

- **A comp is a designed screen, not a picture of the subject.** Lead the prompt with the screen's own structure, top to bottom, with scale relationships: status bar at 9:41, navigation bar with a large title or none, the regions in order, the tab bar or bottom accessory, the home indicator. A screen with no tab bar says so. An unconventional skeleton is stated literally. A prompt that leads with atmosphere gets a vignette back: the model paints the bakery instead of the bakery's app. If the render could hang as a poster or reads as a photograph with some text on it, it is not a comp; regenerate with the scaffold stated more literally.
- **The subject must be in it.** The world dresses the frame; it never displaces what the frame shows. Before accepting a render, point at the subject's content: the entries, the recipe, the route, the balance. A render that depicts everything about the world and nothing of the subject fails however faithful its atmosphere.
- **The job must read from the image alone.** Name the screen's mode and primary action from the render with no caption. If you cannot, regenerate with the user's job as the prompt's spine.
- **Commitment is depth, not coverage.** The world enters through one dominant move plus the material, type, and spacing that support it; the other regions hold still so that move can be read. A second element competing with the focal moment at the same scale means the comp is shouting. Quiet a region by stopping its performance, never by deleting its information. Busy is louder, not bolder.
- **Native, not ported.** Bars, controls, and gestures read as the platform's: real tab bar geometry, real sheet grabbers, controls at 44 pt, text at believable Dynamic Type sizes. A comp that invents a web-style hamburger nav has drawn a different product.
- **Real content only.** Real product name, real feature names, sample data that looks like sample data. No invented prices, ratings, reviews, award badges, or subscriber counts.
- Spread the three across shortlisted concepts when the user shortlisted several; otherwise vary what an image can resolve: topology, sequence, density, hierarchy, focal composition, interaction framing. Do not generate a palette sheet, ask new atmosphere questions, change the type voice, or invent a new motif; if the world cannot carry the concept, return to the concept list rather than changing the world.

Each comp is a direction test, not a specification of copy, accessibility, Dynamic Type behavior, or states; those remain implementation responsibilities.

## One approval point

Show the three together: open them for the user (`open .impeccable/mocks/<surface>/comp-*.png` opens them in Preview), and display them inline when the harness renders images to the user. Then ask with AskUserQuestion: which comp carries forward, what feels false to the world, and whether to approve, combine, revise, or reject. Stop and wait.

Do not write Swift until the user approves a comp or explicitly delegates the choice. A delegated pick is chosen from the brief, PRODUCT.md, and DESIGN.md, stated with its evidence, recorded exactly as an approval is, and disclosed in your first reply. This approval point has no skip condition; only a probe that errors or times out makes the choice delegated. Approval refines the surface concept; it does not modify DESIGN.md.

Record the approval where later agents look: the approved comp's path and a two-line summary under `## Approved comp` in the surface brief, including which parts of the comp must not be literalized, and `"approved": true` in its sidecar. The finish reviewer treats comps under `.impeccable/mocks/<surface>/` with no recorded approval as a material finding; files under `.impeccable/mocks/decision/` are the direction round's hand and imply no approval.

## After approval: the comp becomes a spec

The approved comp is a north star for translation into semantic, adaptive, accessible SwiftUI, never a license to recompose: keeping the palette while redrawing the topology is a second art direction. Never rasterize text, controls, or bars. Never substitute a different visual driver without asking.

The medium of every region follows from what the pixels are, never from what feels buildable. A figure, a product object, an illustration with perspective, shading, or drawing skill, a photograph, and any named texture (paper grain, linen, brushed metal, film grain) is a raster and ships as an asset. Text, controls, bars, lists, charts drawn from data, diagrams with countable elements, and flat shape systems are SwiftUI. Writing "a `LinearGradient` and a shadow" for a sculpted surface, or a `Path` with forty points for a torn paper edge, is the quiet deletion of the approved design. Dropping an image-native region is a scope decision the user makes at the approval point, never a silent flattening after it.

### Region map

Name everything the comp shows in a `## Region map` table in the surface brief, before any asset is produced. Read the comp's size with `sips -g pixelWidth -g pixelHeight <comp>`; boxes are normalized `x, y, w, h` from the top-left, so they hold on every device.

```markdown
## Region map
Comp: .impeccable/mocks/onboarding/comp-2.png (1206×2622)

| id | kind | box (x, y, w, h) | parent / group | note | ships as | status |
|---|---|---|---|---|---|---|
| hero-plate | plate | 0.00, 0.08, 1.00, 0.46 | | risograph pear on ink-blue field, cut edge at bottom | `Image("OnboardingPear")`, transparent | |
| title | text | 0.08, 0.57, 0.84, 0.10 | | "Know what's ripe." two lines, heavy compressed | `Text` in `.brandDisplay` (`relativeTo: .largeTitle`) | |
| page-dots | control | 0.40, 0.84, 0.20, 0.02 | | three dots, current one elongated | custom `PageIndicator` | |
| start | control | 0.06, 0.88, 0.88, 0.06 | | full-width capsule, cream on ink | `Button` + `InkCapsuleStyle` | |
```

Kinds: `plate` (isolated artwork, usually transparent), `image` (photograph or full-frame illustration, opaque), `texture` (a tileable material), `symbol` (a pictogram: an SF Symbol or a custom symbol), `text`, `control`, `chrome` (bars and system-shaped regions), `container` (a region that only lays out its children). The `status` column is filled during the first-screen phase with `match`, `drift`, `missing`, or `contradicted`.

Rules that keep the map honest:

- **Name every piece of ink.** Callouts, a caption under a chart, a badge on a row: what is never named can never be missing.
- **No text or control region over a quarter of the screen.** That is a column, not an element; name each element inside it and mark the column `container`.
- **A plate's box holds its whole artwork with a margin.** A box that cuts through the drawing ships the drawing minus the side it lost.
- **Arrows and leader lines belong to their drawing's plate**; only their labels are text.
- **`parent`** names an enclosing container; **`group`** names repeated instances of one component in one role (three onboarding bullets), never all the parts of one card. Grouping keeps every row; it never waives a check.

Cut a reference crop per raster region for the asset producer: `sips --cropToHeightWidth <h> <w> --cropOffset <y> <x> <comp> --out .impeccable/mocks/<surface>/crops/<id>.png`, converting the normalized box to pixels. Open each crop and confirm it holds its named subject and nothing of its neighbors; fix the box before producing anything, never build to a known bad crop. A crop is reference evidence, never a shipping pixel.

## Produce

Every raster region ships as a plate: the region regenerated at asset resolution from its crop, same subject, composition, palette, lighting, and material, with UI text and chrome removed. With parallel subagents, spawn `impeccable-swiftui-asset-producer` with the surface brief, the approved comp, the crops directory, and the target asset catalog; otherwise produce here following that agent's procedure.

- **Resolution.** A comp at native resolution already measures in @3x pixels. The master is at least the region's pixel size, 1.5× preferred for downsampling headroom; derive @2x with `sips -Z`. A tool that cannot reach the size is reported as under-resolution, never silently upscaled.
- **Background.** Isolated figures, objects, and line drawings on the screen's ground are transparent PNG cutouts, so they sit on the asset-catalog color beneath them in both appearances. Photographs, full-frame art, and textures are opaque. Check real alpha (`sips -g hasAlpha`), then inspect the cutout on light and dark grounds: white paint stays solid, holes clear, no halos. Never chroma-key.
- **Appearance.** When the comp's world has a dark rendition that changes the art (not just the ground), produce a dark variant into the same imageset's Dark appearance.
- **Textures** ship as a clean tileable patch drawn with `Image(...).resizable(resizingMode: .tile)`, generated only when no clean patch exists in the crop.
- **Vectors.** Flat shapes, marks, and diagrams that must stay crisp at every Dynamic Type size are authored as SVG or PDF, set to single scale with Preserve Vector Data. Product nouns that need icons become custom SF Symbols exported from the SF Symbols app's template into a `.symbolset`, so they take weight, scale, and rendering mode like the rest.
- **App icon.** Layered artwork for Icon Composer (foreground layers as transparent PNG or SVG, background separate) on iOS 26 and later, or an `AppIcon.appiconset` single 1024×1024 with Dark and Tinted variants for earlier targets.
- **Placement.** Each asset lands in the target `Assets.xcassets` under a role name from the region map (`OnboardingPear`, not `image-2`) with a correct `Contents.json`.

**Provenance.** Every raster the app references carries it: `.impeccable/assets/<AssetName>.json` with the exact prompt the tool received, the tool, the reference crop, the background mode, the master size, and the region id; a sourced, stock, or pre-existing raster records its origin and license instead. Provenance lives beside the catalog, never inside an imageset folder, where Xcode would flag an unassigned child. A raster created or replaced later, in a fix batch or a rebuild, is produced the same way; a raster a fix abandons is deleted from the catalog and from `.impeccable/assets/` in the same batch.

Then return to [new-work.md](new-work.md): the component kit and [component-review.md](component-review.md), then the first screen.
