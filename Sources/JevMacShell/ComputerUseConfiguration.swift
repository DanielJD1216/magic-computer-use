import Foundation

public enum ComputerUseMode: String, CaseIterable, Identifiable {
    case native
    case bounded
    case experimentalDesktop

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .native:
            return "Native Swift"
        case .bounded:
            return "Bounded CuaDriver"
        case .experimentalDesktop:
            return "Experimental desktop"
        }
    }

    public var summary: String {
        switch self {
        case .native:
            return "Deterministic native execution for the registered fixture."
        case .bounded:
            return "CuaDriver may act only on the registered Safari fixture."
        case .experimentalDesktop:
            return "Future Hermes tasks may target the current Mac session."
        }
    }
}

public enum ComputerUseConfiguration {
    public static let enabledKey = "jev.computerUseExecutorEnabled"
    public static let experimentalDesktopKey = "jev.experimentalDesktopModeEnabled"

    public static var mode: ComputerUseMode {
        return isEnabled ? .bounded : .native
    }

    public static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    public static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: enabledKey)
        if enabled {
            UserDefaults.standard.set(false, forKey: experimentalDesktopKey)
        }
    }

    public static var isExperimentalDesktopEnabled: Bool {
        false
    }

    public static func setExperimentalDesktopEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(false, forKey: experimentalDesktopKey)
    }

    public static func setMode(_ mode: ComputerUseMode) {
        switch mode {
        case .native:
            setEnabled(false)
            setExperimentalDesktopEnabled(false)
        case .bounded:
            setExperimentalDesktopEnabled(false)
            setEnabled(true)
        case .experimentalDesktop:
            setExperimentalDesktopEnabled(false)
            setEnabled(false)
        }
    }
}
