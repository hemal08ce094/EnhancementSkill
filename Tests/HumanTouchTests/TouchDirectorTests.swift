import DesignSkills
import Testing
@testable import HumanTouch

@Suite struct TouchDirectorTests {
    @Test func everyCatalogSlugIsARealTheme() {
        for s in StyleTraits.catalog {
            #expect(DesignTheme.named(s.slug) != nil, "missing theme \(s.slug)")
        }
    }

    @Test func presetsResolveToDistinctStyles() {
        let ids = TouchProfile.presets.map { TouchDirection($0).theme.id }
        #expect(Set(ids).count == ids.count, "\(ids)")
    }

    @Test func highStakesNeverGetsAPlayfulStyleOrSketchedControls() {
        for e in stride(from: 0.0, through: 1, by: 0.25) {
            for w in stride(from: 0.0, through: 1, by: 0.25) {
                for c in stride(from: 0.0, through: 1, by: 0.25) {
                    let d = TouchDirection(TouchProfile(name: "x", energy: e, warmth: w, craft: c, stakes: .high))
                    let traits = StyleTraits.catalog.first { $0.slug == d.theme.id }!
                    #expect(traits.maxStakes == .high)
                    #expect(d.handDrawn != .controls)
                    #expect(d.haptics == .subtle)
                }
            }
        }
    }

    @Test func glanceAppsStayClean() {
        var p = TouchProfile.playfulMaker
        p.moment = .glance
        #expect(TouchDirection(p).handDrawn == .none)
    }

    @Test func handmadeLowStakesGetsSketchedControls() {
        let d = TouchDirection(.playfulMaker)
        #expect(d.handDrawn == .controls)
        if case .bot = d.assistant {} else { Issue.record("expected a bot") }
    }

    @Test func resolutionIsDeterministicAndExplained() {
        let a = TouchDirection(.calmCompanion), b = TouchDirection(.calmCompanion)
        #expect(a.theme.id == b.theme.id)
        #expect(a.rationale == b.rationale)
        #expect(a.rationale.count >= 3)
    }

    @Test func overrideKeepsTheRestOfTheDirection() {
        let d = TouchDirection(.trustedTool).overriding(theme: "matrix")
        #expect(d.theme.id == "matrix")
        #expect(d.handDrawn == TouchDirection(.trustedTool).handDrawn)
        #expect(TouchDirection(.trustedTool).overriding(theme: "nope").theme.id == TouchDirection(.trustedTool).theme.id)
    }

    @Test func outOfRangeTraitsAreClamped() {
        let p = TouchProfile(name: "x", energy: 7, warmth: -2, craft: .nan)
        #expect(p.energy == 1 && p.warmth == 0 && p.craft == 0.5)
    }
}
