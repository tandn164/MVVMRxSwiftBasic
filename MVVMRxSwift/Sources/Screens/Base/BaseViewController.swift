//
//  BaseViewController.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import UIKit

class BaseViewController: UIViewController {
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return (navigationController?.topViewController == self) && (super.hidesBottomBarWhenPushed)
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    private weak var rootViewController: UIViewController?
    var viewType: ViewType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootViewController = navigationController?.viewControllers.first
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewType = viewType {
            navigationController?.isNavigationBarHidden = viewType.navBarHidden
        }
        if (navigationController?.viewControllers.count ?? 0 > 1) && (rootViewController != self) {
            addBackBarButton()
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let viewType = viewType {
            navigationController?.isNavigationBarHidden = !(viewType.navBarHidden)
        }
    }
    
    func addBackBarButton() {
        let newBackButton = UIBarButtonItem(image: UIImage(named: "chevron_left"),
                                            style: UIBarButtonItem.Style.plain,
                                            target: self,
                                            action: #selector(onBackAction))
        navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func onBackAction() {
        goBack()
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
