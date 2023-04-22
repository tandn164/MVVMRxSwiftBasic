//
//  ViewController.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationUtil.delay(seconds: 3) {
            ViewManager.shared.setTabbarIsRootView()
        }
    }
}

