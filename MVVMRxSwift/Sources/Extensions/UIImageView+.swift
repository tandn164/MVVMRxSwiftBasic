//
//  UIImageView+.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation
import AlamofireImage

extension UIImageView {
    func setImage(withPath path: String?) {
        guard let url = try? path?.asURL() else {
            return
        }
        self.af.setImage(withURL: url)
    }
    
    func setImage(withPath path: String?, placeholderImage placeholder: UIImage? = nil){
        guard let url = try? path?.asURL() else {
            self.image =  placeholder
            return
        }
        self.af.setImage(withURL: url, placeholderImage: placeholder)
    }
}
