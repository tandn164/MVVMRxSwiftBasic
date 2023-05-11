//
//  HeaderRefreshView.swift
//  pos-ios
//
//  Created by Le Chien on 2022/10/27.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: HeaderRefreshView {
    var isRefreshing: Binder<Bool> {
        return Binder(self.base) { refreshControl, refresh in
            if refresh {
                refreshControl.action?()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}

class HeaderRefreshView: UIView {
    
    enum PullState {
        case idle
        case pulling
        case willRefresh
        case willEndRefreshing
        case refreshing
    }
    
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    
    var action: (() -> Void)?
    
    var isDragging: Bool = false
    
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
    
    private var observer: NSKeyValueObservation?
    
    private var contentView: UIView!
    
    private(set) var state = BehaviorRelay<PullState>(value: .idle)
    
    private var isDraggingScrollView: Bool {
        return scrollView.isDragging || isDragging
    }
    
    private var originContentInset: UIEdgeInsets!
    
    private let slowAnimateDuration = 0.4
    private let fastAnimateDuration = 0.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    var isRefreshing: Bool {
        return state.value == .refreshing
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// setup view
    private func setup() {
        contentView = Bundle.main.loadNibNamed("HeaderRefreshView", owner: self, options: nil)?[0] as? UIView
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
        activity.color = .blue
        if #available(iOS 13.0, *) {
            activity.style = .medium
        } else {
        }
    }
    
    /// add kvo
    private func addKVO() {
        observer = scrollView.observe(\UIScrollView.contentOffset, options: [.new, .old]) { [weak self] _, _ in
            self?.contentOffsetChange()
        }
    }
    
    /// scrollview content offset change
    private func contentOffsetChange() {
        if scrollView.isLoadMore() {
            self.isHidden = true
            return
        }
        self.isHidden = false
        
        if state.value == .willEndRefreshing {
            return
        }
        
        let yOffset = scrollView.contentOffset.y
        if yOffset == 0, !isDraggingScrollView {
            state.accept(.idle)
        }
        
        if yOffset > 0 {
            if state.value != .refreshing {
                state.accept(.idle)
            }
        }
        
        if -yOffset > 0 {
            if state.value == .idle {
                state.accept(.pulling)
            }
        }
        
        if !isDraggingScrollView {
            if state.value == .willRefresh {
                state.accept(.refreshing)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.arrowImageView.isHidden = true
                    self.activity.startAnimating()
                    UIView.animate(withDuration: self.fastAnimateDuration, animations: {
                        let top = self.frame.height
                        self.scrollView.contentInset.top = top
                        
                        var offset = self.scrollView.contentOffset
                        offset.y = -top
                        self.scrollView.setContentOffset(offset, animated: false)
                    }, completion: { (_) in
                        self.action?()
                    })
                }
            }
        }
        
        if -yOffset >= self.bounds.height {
            UIView.animate(withDuration: self.fastAnimateDuration) {
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
            }
            if state.value == .pulling {
                state.accept(.willRefresh)
            }
        } else {
            if isDraggingScrollView {
                if state.value == .willRefresh {
                    state.accept(.pulling)
                }
            }
            UIView.animate(withDuration: self.fastAnimateDuration) {
                self.arrowImageView.transform = .identity
            }
        }
        
        contentView.center.x = scrollView.center.x + scrollView.contentOffset.x
    }
    
    /// remove pull to refresh
    func removePullToRefresh() {
        endRefreshing { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
    /// end refresh
    /// - Parameter completion: the block which will be called automatically when end refresh
    func endRefreshing(completion: (() -> Void)? = nil) {
        if state.value == .refreshing {
            state.accept(.willEndRefreshing)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: self.slowAnimateDuration, animations: {
                    self.scrollView.contentInset.top = self.originContentInset.top
                }) { (_) in
                    self.activity.stopAnimating()
                    self.arrowImageView.isHidden = false
                    self.state.accept(.idle)
                    completion?()
                }
            }
        } else {
            state.accept(.idle)
            completion?()
        }
    }
    
    func triggerRefreshing() {
        if state.value != .refreshing {
            state.accept(.refreshing)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.arrowImageView.isHidden = true
                self.activity.startAnimating()
                let top = self.frame.height
                self.scrollView.contentInset.top = top
                var offset = self.scrollView.contentOffset
                offset.y = -top
                self.scrollView.setContentOffset(offset, animated: false)
                self.action?()
            }
        }        
    }
}
