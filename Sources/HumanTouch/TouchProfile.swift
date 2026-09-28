import Foundation

/// Who the app is for and how it should feel to them: the human brief that
/// every visual decision in HumanTouch is derived from.
///
/// Write it from the person's side, not the product's. "A nurse checking a dose
/// at 3am" and "a kid collecting creatures" want different apps even when the
/// screens have the same controls.
public struct TouchProfile: Hashable, Codable, Sendable {
    /// Short name for the profile, e.g. the app's name.
    public var name: String
    /// The people using the app, in one line.
    public var audience: String
    /// What they should feel after using it, in one line ("in control", "cared for").
    public var feeling: String
    /// 0 = calm, still, quiet … 1 = lively, loud, kinetic.
    public var energy: Double
    /// 0 = cool, precise, clinical … 1 = warm, human, friendly.
    public var warmth: Double
    /// 0 = machined, engineered … 1 = handmade, sketched, printed.
    public var craft: Double
    /// What is at risk when the app gets it wrong.
    public var stakes: Stakes
    /// How people spend time in the app.
    public var moment: Moment
    /// Whether the app has an AI assistant or agent, and how present it is.
    public var assistant: AssistantPresence

    public enum Stakes: String, Codable, Sendable, CaseIterable {
        /// Games, toys, hobbies: nothing lost if it misbehaves.
        case low
        /// Everyday utilities, journals, lists.
        case everyday
        /// Money, health, safety, work people are paid for: trust comes first.
        case high
    }

    public enum Moment: String, Codable, Sendable, CaseIterable {
        /// Seconds at a time: check, glance, leave (widgets, timers, weather).
        case glance
        /// Get a job done and get out (forms, lists, tools).
        case task
        /// Stay a while: read, reflect, browse.
        case linger
        /// Play, create, explore.
        case play
    }

    public enum AssistantPresence: String, Codable, Sendable, CaseIterable {
        /// No AI surface.
        case none
        /// AI works in the background; show thinking, not a character.
        case quiet
        /// The assistant is a character people talk to.
        case character
    }

    public init(
        name: String,
        audience: String = "",
        feeling: String = "",
        energy: Double,
        warmth: Double,
        craft: Double,
        stakes: Stakes = .everyday,
        moment: Moment = .task,
        assistant: AssistantPresence = .none
    ) {
        self.name = name
        self.audience = audience
        self.feeling = feeling
        self.energy = energy.clamped
        self.warmth = warmth.clamped
        self.craft = craft.clamped
        self.stakes = stakes
        self.moment = moment
        self.assistant = assistant
    }
}

public extension TouchProfile {
    /// Journals, meditation, sleep, wellbeing: quiet, warm, unhurried.
    static let calmCompanion = TouchProfile(
        name: "Calm companion", audience: "People winding down at the end of the day",
        feeling: "Heard and unhurried",
        energy: 0.15, warmth: 0.8, craft: 0.45, stakes: .everyday, moment: .linger, assistant: .quiet)

    /// Finance, health records, pro tools: precise, trustworthy, calm.
    static let trustedTool = TouchProfile(
        name: "Trusted tool", audience: "Professionals handling things that matter",
        feeling: "In control and certain",
        energy: 0.25, warmth: 0.3, craft: 0.05, stakes: .high, moment: .task, assistant: .quiet)

    /// Kids, learning, creativity, casual games: bright, warm, handmade.
    static let playfulMaker = TouchProfile(
        name: "Playful maker", audience: "Curious people who like to make things",
        feeling: "Delighted and a little proud",
        energy: 0.75, warmth: 0.9, craft: 0.9, stakes: .low, moment: .play, assistant: .character)

    /// Fitness, music, events, streaks: bold, kinetic, confident.
    static let boldPerformer = TouchProfile(
        name: "Bold performer", audience: "People chasing a goal",
        feeling: "Fired up",
        energy: 0.9, warmth: 0.45, craft: 0.25, stakes: .everyday, moment: .glance, assistant: .none)

    /// Presets shown in pickers and the demo.
    static let presets: [TouchProfile] = [.calmCompanion, .trustedTool, .playfulMaker, .boldPerformer]
}

extension Double {
    var clamped: Double { Swift.min(1, Swift.max(0, self.isFinite ? self : 0.5)) }
}
