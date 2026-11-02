# AI customization prompt

Copy the prompt below into a coding-capable AI agent and fill in the bracketed fields.

```text
Customize this macOS ScreenPet repository.

Pet theme: [describe the character, colors, and visual style]
Status source: [game / weather / CPU / stock / API / local metric / other]
Positive condition: [condition]
Negative condition: [condition]
Neutral or waiting condition: [condition]
Refresh frequency: [number of minutes]
Display name: [app name]
Menu-bar symbol: [emoji or short label]

Requirements:
1. Preserve the reusable floating-window framework, dragging, menu-bar controls,
   show-pet behavior, reset-position behavior, and direct swiftc build process.
2. Implement a new Sendable type conforming to StatusProvider. Keep data-source
   logic out of the UI files.
3. Return PetStatus values whose stateID matches the theme's asset mapping.
4. Create or request three consistent transparent 512x512 PNG assets named
   positive.png, negative.png, and neutral.png. Do not use copyrighted logos
   unless I provide permission and the assets.
5. Add a PetTheme, a case in ScreenPetMain.swift configuration(for:), the example
   name and asset folder in build-app.sh, and update README.md consistently.
6. Do not add secrets or API keys to source control. Use environment variables
   or a local ignored configuration file when authentication is required.
7. Avoid SwiftUI external macro dependencies such as @State so the direct
   Command Line Tools build remains compatible.
8. Build with ./build-app.sh <example> --no-open and resolve every compiler error before
   reporting completion.

Explain the state rules and list every file changed.
```

## Examples of state mapping

| Source | Positive | Negative | Neutral |
| --- | --- | --- | --- |
| Baseball / basketball | Team won | Team lost | No final game yet |
| Weather | Sunny | Rain or storms | Fog or clouds |
| CPU | Low usage | Sustained high usage | Moderate usage |
| Stock | Above chosen baseline | Below chosen baseline | Market closed/no change |

For financial or safety-related sources, the pet should be treated as a visual indicator—not professional advice or an emergency alert.
