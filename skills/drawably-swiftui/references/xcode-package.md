# Wiring the Drawably package

Package URL: `https://github.com/hemal08ce094/DrawablySwiftUI`, product `Drawably`, versions from `0.1.0`.

## Swift package manifest

```swift
dependencies: [
    .package(url: "https://github.com/hemal08ce094/DrawablySwiftUI", from: "0.1.0"),
],
targets: [
    .target(name: "App", dependencies: [.product(name: "Drawably", package: "DrawablySwiftUI")]),
]
```

## Xcode project (edit project.pbxproj directly)

Pick four unused 24-hex-digit object IDs: REF, DEP, BUILD, plus the target's existing Frameworks phase ID. Then add:

```
/* Begin PBXBuildFile section */
		BUILD /* Drawably in Frameworks */ = {isa = PBXBuildFile; productRef = DEP /* Drawably */; };
/* End PBXBuildFile section */
```
(If the section already exists, add just the line.)

In the app target's `PBXFrameworksBuildPhase` `files = ( … )`, add `BUILD /* Drawably in Frameworks */,`

In the app's `PBXNativeTarget`, add (or extend):
```
			packageProductDependencies = (
				DEP /* Drawably */,
			);
```

In `PBXProject`, add (or extend):
```
			packageReferences = (
				REF /* XCRemoteSwiftPackageReference "DrawablySwiftUI" */,
			);
```

At the end of `objects`:
```
/* Begin XCRemoteSwiftPackageReference section */
		REF /* XCRemoteSwiftPackageReference "DrawablySwiftUI" */ = {
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/hemal08ce094/DrawablySwiftUI";
			requirement = {
				kind = upToNextMajorVersion;
				minimumVersion = 0.1.0;
			};
		};
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		DEP /* Drawably */ = {
			isa = XCSwiftPackageProductDependency;
			package = REF /* XCRemoteSwiftPackageReference "DrawablySwiftUI" */;
			productName = Drawably;
		};
/* End XCSwiftPackageProductDependency section */
```

Then run `xcodebuild -resolvePackageDependencies` and build. Xcode may reorder sections on its next save; that's fine.

If Xcode is `/Library/Developer/CommandLineTools`, prefix the commands with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

## Local development instead

To edit the library alongside an app, use `XCLocalSwiftPackageReference` with `relativePath = "path/to/DrawablySwiftUI";` in place of the remote reference, and drop `package =` from the product dependency. The repo's own `Demo/DrawablyDemo.xcodeproj` is set up this way.
