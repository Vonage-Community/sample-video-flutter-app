import Foundation
import OpenTok

class OneToOneVideo: NSObject {
    var appDelegate: AppDelegate?
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    var session: OTSession?
    
    init(delegate: AppDelegate){
        appDelegate = delegate
    }
    
    func toggleAudio(publishAudio: Bool) {
        publisher.publishAudio = !publisher.publishAudio
    }
    
    func toggleVideo(publishVideo: Bool) {
        publisher.publishVideo = !publisher.publishVideo
    }
    
    func swapCamera() {
        if publisher.cameraPosition == .front {
            publisher.cameraPosition = .back
        } else {
            publisher.cameraPosition = .front
        }
    }
    
    func initSession(apiKey: String, sessionId: String, token: String) {
        var error: OTError?
        defer {
            // todo
        }
        
        notifyFlutter(state: SdkState.wait)
        session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)!
        session?.connect(withToken: token, error: &error)
    }
    
    func notifyFlutter(state: SdkState) {
        appDelegate?.vonageChannel?.invokeMethod("updateState", arguments: state.rawValue)
    }
}

extension OneToOneVideo: OTSessionDelegate {
    
    func sessionDidConnect(_ sessionDelegate: OTSession) {
        print("The client connected to the session.")
        notifyFlutter(state: SdkState.loggedIn)
        
        var error: OTError?
        defer {
            // todo
        }
        
        self.session?.publish(self.publisher, error: &error)
        
        if let pubView = self.publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
            
            if OpentokVideoFactory.view == nil {
                OpentokVideoFactory.viewToAddPub = pubView
            } else {
                OpentokVideoFactory.view?.addPublisherView(pubView)
            }
        }
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("The client disconnected from the session.")
        notifyFlutter(state: SdkState.loggedOut)
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the session: \(error).")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("A stream was created in the session.")
        var error: OTError?
        defer {
            // todo
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        session.subscribe(subscriber!, error: &error)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
}

extension OneToOneVideo: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

extension OneToOneVideo: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
        
        if let subView = self.subscriber?.view {
            subView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
            
            if OpentokVideoFactory.view == nil {
                OpentokVideoFactory.viewToAddSub = subView
            } else {
                OpentokVideoFactory.view?.addSubscriberView(subView)
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
}
