import Foundation

class OpentokVideoPlatformView: NSObject, FlutterPlatformView {
    private let videoContainer: OpenTokVideoContainer
    
    override init() {
        videoContainer = OpenTokVideoContainer()
        super.init()
    }
    
    public func addSubscriberView(_ view: UIView) {
        videoContainer.addSubscriberView(view)
    }
    
    public func addPublisherView(_ view: UIView) {
        videoContainer.addPublisherView(view)
    }
    
    func view() -> UIView {
        return videoContainer
    }
}
