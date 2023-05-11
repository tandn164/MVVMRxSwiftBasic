//
//  LoadMoreView.swift
//  pos-ios
//
//  Created by Le Chien on 2022/10/27.
//

import UIKit

class LoadMoreView: UIView {
    
    enum LoadMoreState {
        case idle
        case refreshing
        case isRemoving
    }
    
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    
    var action: (() -> Void)?
    
    weak var scrollView: UIScrollView! {
        didSet {
            if scrollView != nil {
                scrollView.alwaysBounceVertical = true
                if #available(iOS 11.0, *) {
                    originContentInset = scrollView.adjustedContentInset
                } else {
                    originContentInset = scrollView.contentInset
                }
                addKVO()
            }
        }
    }
    
    private var originContentInset: UIEdgeInsets!
    
    private var observer: NSKeyValueObservation?
    
    private var observerContentSize: NSKeyValueObservation?
    
    private var contentView: UIView!
    
    private(set) var state: LoadMoreState = .idle 
    
    var isLoadMore: Bool {
        return state == .refreshing
    }
    
    private let slowAnimateDuration = 0.4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// setup view
    private func setup() {
        contentView = Bundle.main.loadNibNamed("LoadMoreView", owner: self, options: nil)?[0] as? UIView
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
    }
    
    /// end load more 
    /// - Parameter completion: the block which will be called automatically when finish end load more
    func endLoadMore(completion: (() -> Void)? = nil) {
        if state == .refreshing {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: self.slowAnimateDuration, animations: {
                    self.scrollView.contentInset.bottom = self.originContentInset.bottom
                }) { (_) in
                    self.activity.stopAnimating()
                    self.state = .idle
                    completion?()
                }
            }
        } else {
            state = .idle
            completion?()
        }
    }
    
    /// remove load more
    func removeLoadMore() {
        state = .isRemoving
        scrollView.contentInset.bottom = originContentInset.bottom
        removeFromSuperview()
    }
    
    /// add kvo
    private func addKVO() {
        observer = scrollView.observe(\UIScrollView.contentOffset, options: [.new, .old]) { [weak self] _, _ in
            self?.contentOffsetChange()
        }
        
        observerContentSize = scrollView.observe(\UIScrollView.contentSize, options: [.new, .old]) { [weak self] _, _ in
            self?.contentSizeChange()
        }
    }
    
    /// scrollview content offset change
    private func contentOffsetChange() {
        if scrollView.isRefreshing() {
            self.isHidden = true
            return
        }
        
        if state == .refreshing || state == .isRemoving {
            return
        }
        
        self.isHidden = false
        let offsetY = scrollView.contentOffset.y
        if offsetY > scrollView.contentSize.height - scrollView.frame.height, offsetY > 0 {
            let shouldLoadMore = scrollView.items > 0
            if state == .idle, (scrollView.isDragging || scrollView.isDecelerating), shouldLoadMore {
                state = .refreshing
                activity.startAnimating()
                scrollView.contentInset.bottom = self.frame.height
                action?()
            }
        }
        
        contentView.center.x = scrollView.center.x + scrollView.contentOffset.x
    }
    
    /// scrollview content size change
    private func contentSizeChange() {
        self.frame.origin.y = scrollView.contentSize.height
    }

}
