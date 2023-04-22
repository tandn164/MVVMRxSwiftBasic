//
//  TopViewModel.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation
import RxSwift

protocol TopViewModelOutput: AnyObject {
    func photosDidGetSuccess()
    func photosDidGetFailed(_ error: Error)
}

protocol TopViewModelType {
    var photos: [Photo] {get}
    func performGetPhotos()
}

class TopViewModel: TopViewModelType {
    var photos: [Photo] = []
    private var disposeBag = DisposeBag()
    private weak var view: TopViewModelOutput?

    init(view: TopViewModelOutput) {
        self.view = view
    }

    func performGetPhotos() {
        let photoAPI = APIProvider().makePhotosAPI()
        photoAPI.fetchPhots().subscribe(onNext: { [weak self] photos in
            self?.photos = photos
            self?.view?.photosDidGetSuccess()
        },onError: { [weak self] error in
            self?.view?.photosDidGetFailed(error)
        }).disposed(by: disposeBag)
    }
}
