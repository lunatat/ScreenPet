import AppKit
import SwiftUI

struct PetView: View {
    @ObservedObject var model: PetModel
    let resetPosition: @MainActor () -> Void

    var body: some View {
        Image(nsImage: image(named: model.theme.assetName(for: model.stateID)))
            .resizable()
            .scaledToFit()
            .frame(width: 178, height: 178)
            .help(model.message)
            .contextMenu {
                Text(model.message)
                Divider()
                Button(model.isRefreshing ? "Refreshing…" : "Refresh Now") {
                    Task { await model.refresh() }
                }
                .disabled(model.isRefreshing)
                Button("Reset Pet Position") {
                    resetPosition()
                }
                Divider()
                Button("Quit \(model.theme.displayName)") {
                    NSApp.terminate(nil)
                }
            }
            .onAppear { model.start() }
            .accessibilityLabel(model.message)
    }

    private func image(named name: String) -> NSImage {
        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }

        if name != model.theme.assetName(for: model.theme.fallbackStateID),
           let fallbackURL = Bundle.main.url(
                forResource: model.theme.assetName(for: model.theme.fallbackStateID),
                withExtension: "png"
           ),
           let fallbackImage = NSImage(contentsOf: fallbackURL) {
            return fallbackImage
        }

        return NSImage(
            systemSymbolName: "pawprint.circle.fill",
            accessibilityDescription: "Status Pet"
        ) ?? NSImage(size: NSSize(width: 128, height: 128))
    }
}
