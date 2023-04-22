//
//  ObservableType+Ex.swift
//  RxSkeleton
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import UIKit
import RxSwift
import RxCocoa

extension ObservableType {
    func subscribeProxyDataSource<DelegateProxy: DelegateProxyType>(ofObject object: DelegateProxy.ParentObject, dataSource: DelegateProxy.Delegate, retainDataSource: Bool, binding: @escaping (DelegateProxy, Event<Self.Element>) -> Void)
        -> Disposable
        where DelegateProxy.ParentObject: UIView {
            let proxy = DelegateProxy.proxy(for: object)
            let unregisterDelegate = DelegateProxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
            // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
            object.layoutIfNeeded()
            
            let subscription = self.asObservable()
                .observe(on: MainScheduler())
                .catch { error in
                    debugFatalError(error)
                    return Observable.empty()
                }
                // source can never end, otherwise it would release the subscriber, and deallocate the data source
                .concat(Observable.never())
                .take(until: object.rx.deallocated)
                .subscribe { event in
                    
                    // assertion deleted
                    
                    binding(proxy, event)
                    
                    switch event {
                    case .error(let error):
                        debugFatalError(error)
                        unregisterDelegate.dispose()
                    case .completed:
                        unregisterDelegate.dispose()
                    default:
                        break
                    }
            }
            
            return Disposables.create { [weak object] in
                subscription.dispose()
                object?.layoutIfNeeded()
                unregisterDelegate.dispose()
            }
    }
}
