import Foundation

class ArchivingPlatformView: NSObject, FlutterPlatformView {
    private let videoContainer: ArchivingContainer
    
    override init() {
        videoContainer = ArchivingContainer()
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
