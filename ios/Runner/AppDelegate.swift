import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var mapsKey = Bundle.main.object(forInfoDictionaryKey: "GMSAPIKey") as? String ?? ""
    if mapsKey.isEmpty || mapsKey.hasPrefix("$") {
      mapsKey = "AIzaSyBrNLpWK0yrWXfxL7PYXFKkUTJH3GsaTh0"
    }
    GMSServices.provideAPIKey(mapsKey)

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
