import AppKit
import SwiftUI

@MainActor
final class StatusPetAppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let model: PetModel
    private let theme: PetTheme
    private var panel: NSPanel?
    private var statusItem: NSStatusItem?

    init(provider: any StatusProvider, theme: PetTheme) {
        self.theme = theme
        self.model = PetModel(provider: provider, theme: theme)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        makePanel()
        makeStatusItem()
        model.onStatusChanged = { [weak self] in
            self?.showPet()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(computerDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        model.start()
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        showPet()
        return true
    }

    private func makePanel() {
        let size = NSSize(width: 190, height: 190)
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = theme.displayName
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.contentView = NSHostingView(
            rootView: PetView(
                model: model,
                resetPosition: { [weak self] in self?.resetPetPosition() }
            )
        )
        panel.setFrameAutosaveName(theme.windowPositionKey)

        if !panel.setFrameUsingName(theme.windowPositionKey) {
            panel.setFrameOrigin(defaultOrigin(for: size))
        }

        panel.orderFrontRegardless()
        self.panel = panel
    }

    private func makeStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = theme.menuBarSymbol
        item.button?.toolTip = theme.displayName
        let menu = NSMenu()
        menu.delegate = self
        item.menu = menu
        statusItem = item
    }

    func menuWillOpen(_ menu: NSMenu) {
        menu.removeAllItems()

        let status = NSMenuItem(title: model.message, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)
        menu.addItem(.separator())

        let refresh = NSMenuItem(
            title: model.isRefreshing ? "Refreshing…" : "Refresh Now",
            action: #selector(refreshNow),
            keyEquivalent: "r"
        )
        refresh.target = self
        refresh.isEnabled = !model.isRefreshing
        menu.addItem(refresh)

        let show = NSMenuItem(title: "Show Pet", action: #selector(showPetAction), keyEquivalent: "")
        show.target = self
        menu.addItem(show)

        let reset = NSMenuItem(title: "Reset Pet Position", action: #selector(resetPetPositionAction), keyEquivalent: "")
        reset.target = self
        menu.addItem(reset)
        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit \(theme.displayName)", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    private func showPet() {
        guard let panel else { return }
        let isOnAnyScreen = NSScreen.screens.contains { $0.visibleFrame.intersects(panel.frame) }
        if !isOnAnyScreen {
            resetPetPosition()
        }
        panel.orderFrontRegardless()
    }

    private func resetPetPosition() {
        guard let panel else { return }
        UserDefaults.standard.removeObject(forKey: "NSWindow Frame \(theme.windowPositionKey)")
        panel.setFrameOrigin(defaultOrigin(for: panel.frame.size))
        panel.orderFrontRegardless()
    }

    private func defaultOrigin(for size: NSSize) -> NSPoint {
        guard let screen = NSScreen.main?.visibleFrame else {
            return NSPoint(x: 40, y: 40)
        }
        return NSPoint(x: screen.maxX - size.width - 24, y: screen.minY + 24)
    }

    @objc private func refreshNow() {
        Task { await model.refresh() }
    }

    @objc private func showPetAction() {
        showPet()
    }

    @objc private func resetPetPositionAction() {
        resetPetPosition()
    }

    @objc private func screenParametersChanged() {
        showPet()
    }

    @objc private func computerDidWake() {
        showPet()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
