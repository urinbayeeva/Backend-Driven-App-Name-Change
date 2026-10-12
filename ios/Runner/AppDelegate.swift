import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "app/icon", binaryMessenger: engineBridge.applicationRegistrar.messenger())
    channel.setMethodCallHandler(AppIconHandler.handle)
  }
}

/// Switches between bundled icon sets named AppIcon-<key>. The home screen
/// name has no runtime API on iOS; it comes from Brand.xcconfig at build time.
enum AppIconHandler {
  // Append-only; must match ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES.
  static let iconKeys: Set<String> = ["rocket", "star", "heart"]

  // Primary icon baked into this build (Info.plist BrandPrimaryIcon).
  static var primaryKey: String {
    Bundle.main.object(forInfoDictionaryKey: "BrandPrimaryIcon") as? String ?? "rocket"
  }

  static var currentKey: String {
    guard let name = UIApplication.shared.alternateIconName else { return primaryKey }
    return String(name.dropFirst("AppIcon-".count))
  }

  static func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    switch call.method {
    case "setIconKey":
      guard let key = (call.arguments as? [String: Any])?["key"] as? String,
        iconKeys.contains(key)
      else {
        result(FlutterError(code: "UNKNOWN_KEY", message: nil, details: nil))
        return
      }
      let app = UIApplication.shared
      guard app.supportsAlternateIcons else { result(false); return }
      // An alternate set with the primary's artwork counts as current:
      // switching would show the system alert for an identical icon.
      guard currentKey != key else { result(true); return }
      guard app.applicationState == .active else {
        result(FlutterError(code: "NOT_ACTIVE", message: nil, details: nil))
        return
      }
      app.setAlternateIconName(key == primaryKey ? nil : "AppIcon-\(key)") { error in
        if let error = error {
          result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
        } else {
          result(true)
        }
      }
    case "currentIconKey":
      result(currentKey)
    case "reconcile":
      // Artwork of a leftover alternate equals the new primary; keep it to
      // avoid the system alert. Only report state.
      result(UIApplication.shared.alternateIconName ?? "primary")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
