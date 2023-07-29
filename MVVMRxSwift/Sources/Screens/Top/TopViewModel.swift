//
//  TopViewModel.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation
import RxSwift
import RxCocoa

class TopViewModel {
    private let _photos = BehaviorRelay<[Photo]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _error = BehaviorRelay<String?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    func fetchPhotos() {
        self._photos.accept([])
        self._isFetching.accept(true)
        self._error.accept(nil)
        
        APIProvider(apiEndpoint: "https://picsum.photos/v2").makePhotosAPI().fetchPhots()
            .subscribe(
                onNext: { [weak self] response in
                    self?._isFetching.accept(false)
                    self?._photos.accept(response)
                },
                onError: { error in
                    self._isFetching.accept(false)
                    self._error.accept(error.localizedDescription)
                }).disposed(by: self.disposeBag)
    }
}

extension TopViewModel {
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var photos: Driver<[Photo]> {
        return _photos.asDriver()
    }
    
    var error: Driver<String?> {
        return _error.asDriver()
    }
    
    var hasError: Bool {
        return _error.value != nil
    }
    
    var numberOfImages: Int {
        return _photos.value.count
    }
    
    func photo(_ index: Int) -> Photo {
        return _photos.value[index]
    }
}
