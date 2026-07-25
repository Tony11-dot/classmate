import Flutter
import UIKit

/// Registers the native glass platform view with Flutter's plugin registry.
class NativeGlassPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let factory = NativeGlassViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "cm_native_glass_view")
    }
}

class NativeGlassViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let params = args as? [String: Any]
        let radius = CGFloat((params?["cornerRadius"] as? Double) ?? 0.0)
        let style = (params?["style"] as? String) ?? "thin"
        let dark = params?["dark"] as? Bool
        return NativeGlassView(frame: frame, cornerRadius: radius, style: style, dark: dark)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class NativeGlassView: NSObject, FlutterPlatformView {
    private let container: UIView

    init(frame: CGRect, cornerRadius: CGFloat, style: String, dark: Bool? = nil) {
        container = UIView(frame: frame)
        container.backgroundColor = .clear

        // The system blur materials resolve against the trait collection, so
        // pin it to the APP's light/dark mode (passed from Flutter). Left nil
        // for callers that want to keep following the OS appearance.
        if let dark = dark {
            container.overrideUserInterfaceStyle = dark ? .dark : .light
        }

        // iOS 26+: the REAL Liquid Glass (UIGlassEffect) — the same native
        // material SwiftUI's `.glassEffect()` uses, i.e. exactly what ClassNotes
        // renders. Older iOS falls back to the system blur materials.
        let effectView: UIVisualEffectView
        if #available(iOS 26.0, *) {
            let glass = UIGlassEffect()
            glass.isInteractive = true
            effectView = UIVisualEffectView(effect: glass)
        } else {
            let blurStyle: UIBlurEffect.Style
            if style == "ultraThin" {
                blurStyle = .systemUltraThinMaterial
            } else if style == "regular" {
                blurStyle = .systemMaterial
            } else {
                blurStyle = .systemThinMaterial
            }
            effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        }
        effectView.frame = frame
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if cornerRadius > 0 {
            container.layer.cornerRadius = cornerRadius
            container.layer.masksToBounds = true
            effectView.layer.cornerRadius = cornerRadius
            effectView.layer.masksToBounds = true
        }

        container.addSubview(effectView)
        super.init()
    }

    func view() -> UIView {
        return container
    }
}
