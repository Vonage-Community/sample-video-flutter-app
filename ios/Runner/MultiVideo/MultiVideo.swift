import Foundation
import OpenTok

class MultiVideo: NSObject {
    var appDelegate: AppDelegate?
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscribers = [OTSubscriber]()
    var streams = [OTStream]()
    var session: OTSession?

    
    init(delegate: AppDelegate){
        appDelegate = delegate
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
        appDelegate?.multiVideoChannel?.invokeMethod("updateState", arguments: state.rawValue)
    }
}

extension MultiVideo: OTSessionDelegate {
    
    func sessionDidConnect(_ sessionDelegate: OTSession) {
        print("The client connected to the session.")
        notifyFlutter(state: SdkState.loggedIn)
        
        var error: OTError?
        defer {
            // todo
        }
        
        self.session?.publish(self.publisher, error: &error)
        
        if let pubView = self.publisher.view {
            
            pubView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            
            if MultiVideoFactory.view == nil {
                MultiVideoFactory.viewToAdd = pubView
            } else {
                MultiVideoFactory.view?.addVideoView(pubView)
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
        let subscriber = OTSubscriber(stream: stream, delegate: self)
        subscribers.append(subscriber!)
        streams.append(stream)
        
        if let subView = subscriber?.view {
            subView.frame = CGRect(x: streams.count*100, y: 0, width: 100, height: 100)
            
            if MultiVideoFactory.view == nil {
                MultiVideoFactory.viewToAdd = subView
            } else {
                MultiVideoFactory.view?.addVideoView(subView)
            }
        }
        session.subscribe(subscriber!, error: &error)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
}

extension MultiVideo: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

extension MultiVideo: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
        
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
}
