//
//  HostingCell.swift
//  CollectionSandbox
//
//  Created by Mateus Rodrigues on 30/04/22.
//

import SwiftUI

extension UIHostingController {
    convenience public init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)
        
        if ignoreSafeArea {
            disableSafeArea()
        }
    }
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}

class CollectionViewHostingCell<Content: View>: UICollectionViewCell {
    
    private var controller: UIHostingController<Content>?
    
    override func prepareForReuse() {
        contentView.backgroundColor = .clear
        if let hostView = controller?.view {
            hostView.removeFromSuperview()
        }
        controller = nil
    }
    
    var content: Content? {
        willSet {
            guard let view = newValue else { return }
            controller = UIHostingController(rootView: view, ignoreSafeArea: true)
            if let hostView = controller?.view {
                hostView.backgroundColor = .clear
                hostView.frame = contentView.bounds
                hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                contentView.addSubview(hostView)
            }
        }
    }
    
}
