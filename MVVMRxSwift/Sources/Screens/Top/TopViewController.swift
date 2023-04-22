//
//  TopViewController.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import UIKit

class TopViewController: BaseViewController {
    private var model: TopViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewType = .top
        model = TopViewModel(view: self)
        model?.performGetPhotos()
    }
}

extension TopViewController: TopViewModelOutput {
    func photosDidGetSuccess() {
        print(model?.photos ?? [])
    }
    
    func photosDidGetFailed(_ error: Error) {
    }
}
