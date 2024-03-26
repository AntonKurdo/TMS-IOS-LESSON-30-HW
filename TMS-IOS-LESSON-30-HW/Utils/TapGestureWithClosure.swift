import UIKit

class UITapGestureRecognizerWithClosure: UITapGestureRecognizer {
    private var invokeTarget:UIGestureRecognizerInvokeTarget
    
    init(closure:@escaping (UIGestureRecognizer) -> ()) {
        self.invokeTarget = UIGestureRecognizerInvokeTarget(closure: closure)
        super.init(target: invokeTarget, action: #selector(invokeTarget.invoke(fromTarget:)))
    }
}


class UIGestureRecognizerInvokeTarget: NSObject {
    private var closure:(UIGestureRecognizer) -> ()
    
    init(closure:@escaping (UIGestureRecognizer) -> ()) {
        self.closure = closure
        super.init()
    }
    
    @objc public func invoke(fromTarget gestureRecognizer: UIGestureRecognizer) {
        self.closure(gestureRecognizer)
    }
}
