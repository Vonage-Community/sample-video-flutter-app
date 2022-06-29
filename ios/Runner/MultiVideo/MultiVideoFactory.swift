import Foundation

class MultiVideoFactory: NSObject, FlutterPlatformViewFactory {
    static var view: MultiVideoPlatformView?
    
    static var viewToAdd: UIView?
    
    static func getViewInstance(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger?
    ) -> MultiVideoPlatformView{
        if(view == nil) {
            view = MultiVideoPlatformView()
            if viewToAdd != nil {
                view?.addVideoView(viewToAdd!)
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
        return MultiVideoFactory.getViewInstance(
            frame: frame,
            viewId: viewId,
            args: args,
            messenger: messenger)
    }
}
