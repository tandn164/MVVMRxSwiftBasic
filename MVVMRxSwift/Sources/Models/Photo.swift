//
//  Photo.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation

struct Photo: Codable {
    let id, author, url, downloadURL: String?
    let width, height: Int?

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
}
