import UIKit
import Flutter
import OpenTok

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var vonageChannel: FlutterMethodChannel?
    var archivingChannel: FlutterMethodChannel?
    var signallingChannel:FlutterMethodChannel?
    var multiVideoChannel:FlutterMethodChannel?
    var screenSharingChannel:FlutterMethodChannel?
    
    var oneToOneVideoMethodChannel = "com.vonage.one_to_one_video"
    var archivingMethodChannel = "com.vonage.archiving"
    var signallingMethodChannel = "com.vonage.signalling"
    var multiVideoMethodChannel = "com.vonage.multi_video"
    var screenSharingMethodChannel = "com.vonage.screen_sharing"
    
    var oneToOneVideo: OneToOneVideo?
    var archiving: Archiving?
    var signalling: Signalling?
    var multiVideo: MultiVideo?
    var screenSharing: ScreenSharing?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        setPlatformViews()
        addFlutterChannelListener()
        
        oneToOneVideo = OneToOneVideo(delegate: self)
        archiving = Archiving(delegate: self)
        signalling = Signalling(delegate: self)
        multiVideo = MultiVideo(delegate: self)
        screenSharing = ScreenSharing(delegate: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setPlatformViews(){
        weak var registrar = self.registrar(forPlugin: "com.vonage")
        
        self.registrar(forPlugin: "<com.vonage>")!.register(
            OpentokVideoFactory(messenger: registrar!.messenger()),
            withId: "opentok-video-container")
        
        self.registrar(forPlugin: "<com.vonage>")!.register(
            ArchivingFactory(messenger: registrar!.messenger()),
            withId: "opentok-archiving-container")
        
        self.registrar(forPlugin: "<com.vonage>")!.register(
            MultiVideoFactory(messenger: registrar!.messenger()),
            withId: "opentok-multi-video-container")
        
        self.registrar(forPlugin: "<com.vonage>")!.register(
            ScreenSharingFactory(messenger: registrar!.messenger()),
            withId: "opentok-screenshare-container")
        
    }
    
    func addFlutterChannelListener() {
        let controller = window?.rootViewController as! FlutterViewController
        
        setOneToOneVideoMethodChannel(controller: controller)
        setArchivingMethodChannel(controller: controller)
        setSignallingMethodChannel(controller: controller)
        setMultiVideoMethodChannel(controller: controller)
        setScreenSharingMethodChannel(controller: controller)
    }
    
    func setScreenSharingMethodChannel(controller: FlutterViewController) {
        screensharingChannel = FlutterMethodChannel(name: screenSharingMethodChannel,
                                             binaryMessenger: controller.binaryMessenger)
        screensharingChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "initSession":
                if let arguments = call.arguments as? [String: String] {
                    
                    let apiKey = arguments["apiKey"]!
                    let sessionId = arguments["sessionId"]!
                    let token = arguments["token"]!
                    
                    self.screenSharing?.initSession(apiKey: apiKey, sessionId: sessionId, token: token)
                }
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    func setMultiVideoMethodChannel(controller: FlutterViewController) {
        multiVideoChannel = FlutterMethodChannel(name: multiVideoMethodChannel,
                                             binaryMessenger: controller.binaryMessenger)
        multiVideoChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "initSession":
                if let arguments = call.arguments as? [String: String] {
                    
                    let apiKey = arguments["apiKey"]!
                    let sessionId = arguments["sessionId"]!
                    let token = arguments["token"]!
                    
                    self.multiVideo?.initSession(apiKey: apiKey, sessionId: sessionId, token: token)
                }
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    func setSignallingMethodChannel(controller: FlutterViewController) {
        signallingChannel = FlutterMethodChannel(name: signallingMethodChannel,
                                             binaryMessenger: controller.binaryMessenger)
        signallingChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "initSession":
                if let arguments = call.arguments as? [String: String] {
                    
                    let apiKey = arguments["apiKey"]!
                    let sessionId = arguments["sessionId"]!
                    let token = arguments["token"]!
                    
                    self.signalling?.initSession(apiKey: apiKey, sessionId: sessionId, token: token)
                }
                result("")
            case "sendMessage":
                if let arguments = call.arguments as? [String: String] {
                    
                    let message = arguments["message"]!
                
                    self.signalling?.sendMessage(message: message)
                }
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    func setArchivingMethodChannel(controller: FlutterViewController) {
        archivingChannel = FlutterMethodChannel(name: archivingMethodChannel,
                                             binaryMessenger: controller.binaryMessenger)
        archivingChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "initSession":
                self.archiving?.getSession()
                result("")
            case "startArchive":
                self.archiving?.startArchive()
                result("")
            case "stopArchive":
                self.archiving?.stopArchive()
                result("")
            case "playArchive":
                self.archiving?.playArchive()
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    func setOneToOneVideoMethodChannel(controller: FlutterViewController) {
        vonageChannel = FlutterMethodChannel(name: oneToOneVideoMethodChannel,
                                             binaryMessenger: controller.binaryMessenger)
        vonageChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "initSession":
                if let arguments = call.arguments as? [String: String] {
                    
                    let apiKey = arguments["apiKey"]!
                    let sessionId = arguments["sessionId"]!
                    let token = arguments["token"]!
                    
                    self.oneToOneVideo?.initSession(apiKey: apiKey, sessionId: sessionId, token: token)
                }
                result("")
            case "swapCamera":
                self.oneToOneVideo?.swapCamera()
                result("")
            case "toggleAudio":
                if let arguments = call.arguments as? [String: Bool],
                   let publishAudio = arguments["publishAudio"] {
                    self.oneToOneVideo?.toggleAudio(publishAudio: publishAudio)
                }
                result("")
            case "toggleVideo":
                if let arguments = call.arguments as? [String: Bool],
                   let publishVideo = arguments["publishVideo"] {
                    self.oneToOneVideo?.toggleVideo(publishVideo: publishVideo)
                }
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
}
