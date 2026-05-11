import Foundation

// Walk up from the current working directory until we find a directory
// containing `FigmaDemo/Assets.xcassets`. Lets the tool be run from the
// repo root, from Tools/AssetGen, or from within .build.
func findRepoRoot(startingFrom start: URL) -> URL? {
    let fm = FileManager.default
    var current = start
    for _ in 0..<8 {
        let candidate = current.appendingPathComponent("FigmaDemo/Assets.xcassets")
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: candidate.path, isDirectory: &isDir), isDir.boolValue {
            return current
        }
        let parent = current.deletingLastPathComponent()
        if parent.path == current.path { break }
        current = parent
    }
    return nil
}

let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
guard let repoRoot = findRepoRoot(startingFrom: cwd) else {
    FileHandle.standardError.write(Data("error: couldn't locate repo root (no FigmaDemo/Assets.xcassets found upward from \(cwd.path))\n".utf8))
    exit(1)
}

let appIconDir = repoRoot.appendingPathComponent("FigmaDemo/Assets.xcassets/AppIcon.appiconset")
let launchLogoDir = repoRoot.appendingPathComponent("FigmaDemo/Assets.xcassets/LaunchLogo.imageset")
try FileManager.default.createDirectory(at: launchLogoDir, withIntermediateDirectories: true)

func render(
    _ filename: String,
    into dir: URL,
    mode: RenderMode,
    variant: RenderVariant,
    size: CGFloat
) throws {
    let image = IconRenderer.render(mode: mode, variant: variant, size: size)
    let url = dir.appendingPathComponent(filename)
    try PNG.write(image, to: url)
    let displayPath = url.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
    print("  \(displayPath)  (\(Int(size))×\(Int(size)))")
}

print("rendering app icons …")
try render("Icon-Light.png",  into: appIconDir, mode: .light,  variant: .icon, size: 1024)
try render("Icon-Dark.png",   into: appIconDir, mode: .dark,   variant: .icon, size: 1024)
try render("Icon-Tinted.png", into: appIconDir, mode: .tinted, variant: .icon, size: 1024)

print("rendering launch logo …")
try render("LaunchLogo.png",    into: launchLogoDir, mode: .light, variant: .launchLogo, size: 200)
try render("LaunchLogo@2x.png", into: launchLogoDir, mode: .light, variant: .launchLogo, size: 400)
try render("LaunchLogo@3x.png", into: launchLogoDir, mode: .light, variant: .launchLogo, size: 600)

print("done.")
