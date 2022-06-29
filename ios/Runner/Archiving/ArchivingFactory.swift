import Foundation

class ArchivingFactory: NSObject, FlutterPlatformViewFactory {
    static var view: ArchivingPlatformView?
    
    static var viewToAddSub: UIView?
    static var viewToAddPub: UIView?
    
    static func getViewInstance(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger?
    ) -> ArchivingPlatformView{
        if(view == nil) {
            view = ArchivingPlatformView()
            if viewToAddSub != nil {
                view?.addSubscriberView(viewToAddSub!)
            }
            if viewToAddPub != nil {
                view?.addPublisherView(viewToAddPub!)
            }
        }
        
        return view!
    }
    
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return ArchivingFactory.getViewInstance(
            frame: frame,
            viewId: viewId,
            args: args,
            messenger: messenger)
    }
}
