//
//  RxSkeleton.swift
//  RxSkeleton
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation

internal func debugFatalError(_ e: Error) {
    #if DEBUG
    fatalError("\(e)")
    #else
    print("\(e)")
    #endif
}
