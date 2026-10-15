# BillBubbles

A monthly bill tracker for iOS (SwiftUI, iOS 17+) with a bubbly Frutiger Aero look.

## Test it without a Mac (free)

1. Make a free account at github.com.
2. Create a new **public** repository (public repos get free macOS build time).
3. Upload everything from this folder into it, keeping the folder structure
   (`project.yml`, the `BillBubbles` folder, and the `.github/workflows/build.yml` file).
   If the hidden `.github` folder won't upload, use Add file > Create new file in GitHub,
   type `.github/workflows/build.yml` as the name, and paste in the contents of `build-workflow.yml`.
4. Open the **Actions** tab. The "Build and screenshot" run starts automatically (about 5-10 minutes).
5. When it finishes, open the run and download the **screenshots** artifact at the bottom.
   If it fails, download **build-log** and send it to Claude to fix.

## Later, with a Mac

Install XcodeGen (`brew install xcodegen`), run `xcodegen generate`, and open `BillBubbles.xcodeproj`.
