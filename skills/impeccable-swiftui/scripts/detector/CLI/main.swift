// Entry point for the impeccable-swiftui detector.
// Builds two ways: as the SwiftPM executable target (depends on ImpeccableDetector)
// and via plain `swiftc` with Core/*.swift + this file as a single module.
#if canImport(ImpeccableDetector)
import ImpeccableDetector
#endif
import Foundation

setvbuf(stdout, nil, _IOLBF, 0)
exit(ImpeccableCLI.run(Array(CommandLine.arguments.dropFirst())))
