import Foundation

final class OpenTokVideoContainer: UIView {
    private let subscriberContainer = UIView()
    private let publisherContainer = UIView()
    
    init() {
        super.init(frame: .zero)
        addSubview(subscriberContainer)
        addSubview(publisherContainer)
    }
    
    
    public func addSubscriberView(_ view: UIView) {
        subscriberContainer.addSubview(view)
    }
    
    public func addPublisherView(_ view: UIView) {
        publisherContainer.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.width
        let height = frame.height
        
        let videoWidth = width / 2
        subscriberContainer.frame = CGRect(x: 0, y: 0, width: videoWidth, height: height)
        publisherContainer.frame = CGRect(x: videoWidth, y: 0, width: videoWidth, height: height)
    }
}
