//
//  APIProvider.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation

class APIProvider {
    private let apiEndpoint: String

    public init() {
        apiEndpoint = "https://picsum.photos/v2"
    }

    func makePhotosAPI() -> PhotosAPI {
        let api = API<Photo>(apiEndpoint)
        return PhotosAPI(api: api)
    }
}
