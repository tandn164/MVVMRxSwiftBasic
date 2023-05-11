//
//  BaseRxViewController.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 11/05/2023.
//

import UIKit
import RxSwift
import RxCocoa

class BaseRxViewController: UIViewController {
    let didLoad = PublishSubject<Void>()
    let willAppear = PublishSubject<Void>()
    let willDisappear = PublishSubject<Void>()
    let didAppear = PublishSubject<Void>()
    let didDisappear = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didLoad.onNext(())
        notiDidloadEvent(self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear.onNext(())
        notiWillAppearEvent(self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappear.onNext(())
        notiWillDisappearEvent(self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear.onNext(())
        notiDidAppearEvent(self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisappear.onNext(())
        notiDidDisappearEvent(self.view)
    }
    
    private func notiDidloadEvent(_ view: UIView?) {
        if let view = view as? BaseRxView {
            view.viewDidLoad()
        }
        view?.subviews.forEach({ subview in
            self.notiDidloadEvent(subview)
        })
    }
    
    private func notiWillAppearEvent(_ view: UIView?) {
        if let view = view as? BaseRxView {
            view.viewWillAppear()
        }
        view?.subviews.forEach({ subview in
            self.notiWillAppearEvent(subview)
        })
    }
    
    private func notiWillDisappearEvent(_ view: UIView?) {
        if let view = view as? BaseRxView {
            view.viewWillDisappear()
        }
        view?.subviews.forEach({ subview in
            self.notiWillDisappearEvent(subview)
        })
    }
    
    private func notiDidAppearEvent(_ view: UIView?) {
        if let view = view as? BaseRxView {
            view.viewDidAppear()
        }
        view?.subviews.forEach({ subview in
            self.notiDidAppearEvent(subview)
        })
    }
    
    private func notiDidDisappearEvent(_ view: UIView?) {
        if let view = view as? BaseRxView {
            view.viewDidDisappear()
        }
        view?.subviews.forEach({ subview in
            self.notiDidDisappearEvent(subview)
        })
    }
}
