import Foundation

final class MultiVideoContainer: UIView {
    private let mainContainer = UIView()
    
    init() {
        super.init(frame: .zero)
        addSubview(mainContainer)
    }
    
    
    public func addVideoView(_ view: UIView) {
        mainContainer.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.width
        let height = frame.height
        mainContainer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
}
