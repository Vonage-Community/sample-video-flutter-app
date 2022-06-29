import Foundation
import OpenTok

class Signalling: NSObject {
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var appDelegate: AppDelegate?
    var signal_type = "text-signal"
    
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
        appDelegate?.vonageChannel?.invokeMethod("updateState", arguments: state.rawValue)
    }
    
    func sendMessage(message: String) {
        session?.signal(withType: signal_type, string: message, connection: nil, error: nil)
    }
    
    func showMessage(message: String, remote: Bool) {
        let arguments = ["message" : message, "remote": remote] as [String : Any]
        appDelegate?.signallingChannel?.invokeMethod("updateMessages", arguments: arguments)
    }
    
}

extension Signalling: OTSessionDelegate {
    
    func sessionDidConnect(_ sessionDelegate: OTSession) {
        print("The client connected to the session.")
        
        var error: OTError?
        self.session?.publish(self.publisher, error: &error)
        
        notifyFlutter(state: SdkState.loggedIn)
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
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
}

extension Signalling: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
    
    func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        var isSelf = false
        if (connection?.connectionId == session.connection?.connectionId) {
            isSelf = true
        }
        showMessage(message: string!, remote: isSelf)
        
    }
}
