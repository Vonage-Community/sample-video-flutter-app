import Foundation

class MultiVideoPlatformView: NSObject, FlutterPlatformView {
    private let videoContainer: MultiVideoContainer
    
    override init() {
        videoContainer = MultiVideoContainer()
        super.init()
    }
    
    public func addVideoView(_ view: UIView) {
        videoContainer.addVideoView(view)
    }
    
    func view() -> UIView {
        return videoContainer
    }
}
