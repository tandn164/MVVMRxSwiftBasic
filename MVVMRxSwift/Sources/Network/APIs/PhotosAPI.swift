//
//  PhotosAPI.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation
import RxSwift

class PhotosAPI {
    private let api: API<Photo>

    init(api: API<Photo>) {
        self.api = api
    }

    func fetchPhots() -> Observable<[Photo]> {
        return api.getItems("list")
    }
}
