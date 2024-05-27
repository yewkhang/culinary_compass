import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // GOOGLE MAPS API KEY
    GMSServices.provideAPIKey("AIzaSyDV1RmA2Pm1bvj8nUSSYJox2sfEO_jMti8")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
