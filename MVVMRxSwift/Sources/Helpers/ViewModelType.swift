//
//  ViewModelType.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 23/04/2023.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
