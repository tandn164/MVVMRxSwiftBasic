//
//  BaseRxView.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 11/05/2023.
//

import UIKit
import RxSwift
import RxCocoa

class BaseRxView: UIView {
    let didLoad = PublishSubject<Void>()
    let willAppear = PublishSubject<Void>()
    let willDisappear = PublishSubject<Void>()
    let didAppear = PublishSubject<Void>()
    let didDisappear = PublishSubject<Void>()
    
    func viewDidLoad() {
        didLoad.onNext(())
    }
    
    func viewWillAppear() {
        willAppear.onNext(())
    }
    
    func viewWillDisappear() {
        willDisappear.onNext(())
    }
    
    func viewDidAppear() {
        didAppear.onNext(())
    }
    
    func viewDidDisappear() {
        didDisappear.onNext(())
    }
}
