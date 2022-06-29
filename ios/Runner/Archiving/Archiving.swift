import Foundation
import UIKit
import OpenTok

class Archiving: NSObject {
    var appDelegate: AppDelegate?
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    var session: OTSession?
    
    var sessionId: String?
    var currentArchiveId: String?
    var playableArchiveId: String?
    
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
    
    func getSession() {
        var urlPath:String! = ServerConfig().CHAT_SERVER_URL
        urlPath.append(contentsOf: "/session")
        let url = URL(string: urlPath)!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let apiDetails = try JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
                    self.initSession(apiKey: apiDetails["apiKey"]!, sessionId: apiDetails["sessionId"]!, token: apiDetails["token"]!)
                } catch {
                    print("json error: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }
        task.resume()
        
    }
    
    func startArchive() {
        if (session != nil) {
            var urlPath:String! = ServerConfig().CHAT_SERVER_URL
            urlPath.append(contentsOf: "/archive/start")
            let url = URL(string: urlPath)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let dic = ["sessionId": sessionId]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                request.httpBody = jsonData
            } catch {
                print(error.localizedDescription)
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if data != nil {
                    
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                }
            }
            task.resume()
        }
    }
    
    func stopArchive() {
        var urlPath:String! = ServerConfig().CHAT_SERVER_URL
        urlPath.append(contentsOf: "/archive/")
        urlPath.append(contentsOf: currentArchiveId!)
        urlPath.append(contentsOf: "/stop")
        let url = URL(string: urlPath)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }
        task.resume()
    }
    
    func playArchive(){
        var urlPath:String! = ServerConfig().CHAT_SERVER_URL
        urlPath.append(contentsOf: "/archive/")
        urlPath.append(contentsOf: currentArchiveId!)
        urlPath.append(contentsOf: "/view")
        
        if let url = URL(string: urlPath) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func notifyFlutter(state: SdkState) {
        appDelegate?.archivingChannel?.invokeMethod("updateState", arguments: state.rawValue)
    }
    
    func updateFlutterArchiving(isArchiving: Bool) {
        appDelegate?.archivingChannel?.invokeMethod("updateArchiving", arguments: isArchiving)
    }
}

extension Archiving: OTSessionDelegate {
    
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
            
            if ArchivingFactory.view == nil {
                ArchivingFactory.viewToAddPub = pubView
            } else {
                ArchivingFactory.view?.addPublisherView(pubView)
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
    
    func session(_ session: OTSession, archiveStartedWithId archiveId: String, name: String?) {
        currentArchiveId = archiveId
        updateFlutterArchiving(isArchiving: true)
    }
    
    func session(_ session: OTSession, archiveStoppedWithId archiveId: String) {
        playableArchiveId = archiveId
        currentArchiveId = nil
        updateFlutterArchiving(isArchiving: false)
    }
}

extension Archiving: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

extension Archiving: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
        
        if let subView = self.subscriber?.view {
            subView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
            
            if ArchivingFactory.view == nil {
                ArchivingFactory.viewToAddSub = subView
            } else {
                ArchivingFactory.view?.addSubscriberView(subView)
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
}
