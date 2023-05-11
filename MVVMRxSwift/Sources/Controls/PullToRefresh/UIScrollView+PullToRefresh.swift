//
//  UIScrollView+PullToRefresh.swift
//  pos-ios
//
//  Created by Le Chien on 2022/10/27.
//

import Foundation
import UIKit

private var tokenHeader = "tokenHeaderRefresh"

private var tokenLoadMore = "tokenLoadMore"

extension UIScrollView {
    
    static let refreshHeight: CGFloat = 44
    
    /// add pull to refresh control
    /// - Parameter action: the block which will be called automatically when pull refresh
    func addRefreshControl(action: (() -> Void)? = nil) {
        guard headerRefresh == nil else { return }
        let header = HeaderRefreshView.init(frame: CGRect.init(x: 0, y: -UIScrollView.refreshHeight, width: self.frame.size.width, height: UIScrollView.refreshHeight))
        header.autoresizingMask = .flexibleWidth
        header.action = action
        header.scrollView = self
        self.insertSubview(header, at: 0)
        objc_setAssociatedObject(self, &tokenHeader, header, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func triggerRefreshing(action: (() -> Void)? = nil) {
        if headerRefresh == nil {
            addRefreshControl(action: action)
        }
        headerRefresh?.triggerRefreshing()
    }
    
    /// refresh control view
    var headerRefresh: HeaderRefreshView? {
        return objc_getAssociatedObject(self, &tokenHeader) as? HeaderRefreshView
    }
    
    /// remove pull to refresh
    func removeRefreshControl() {
        guard let headerRefresh = headerRefresh else {
            return
        }
        objc_setAssociatedObject(self, &tokenHeader, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        headerRefresh.removePullToRefresh()
    }
    
    /// end pull to refresh
    func endRefreshing() {
        headerRefresh?.endRefreshing()
    }
    
    /// isRefreshing
    func isRefreshing() -> Bool {
        return headerRefresh?.isRefreshing ?? false
    }
    
    /// add load more control
    /// - Parameter action: the block which will be called automatically when load more
    func addLoadMore(action: @escaping () -> Void) {
        guard loadMoreView == nil else { return }
        let loadMore = LoadMoreView.init(frame: CGRect.init(x: 0, y: self.contentSize.height, width: self.frame.size.width, height: UIScrollView.refreshHeight))
        loadMore.autoresizingMask = .flexibleWidth
        loadMore.action = action
        loadMore.scrollView = self
        self.insertSubview(loadMore, at: 0)
        objc_setAssociatedObject(self, &tokenLoadMore, loadMore, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// load more view
    var loadMoreView: LoadMoreView? {
        return objc_getAssociatedObject(self, &tokenLoadMore) as? LoadMoreView
    }
    
    /// remove load more control
    func removeLoadMore() {
        guard let loadMoreView = loadMoreView else {
            return
        }
        objc_setAssociatedObject(self, &tokenLoadMore, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        loadMoreView.removeLoadMore()
    }
    
    /// end load more
    func endLoadMore() {
        loadMoreView?.endLoadMore()
    }
    
    /// is load more
    func isLoadMore() -> Bool {
        return loadMoreView?.isLoadMore ?? false
    }
    
    var items: Int {
        var items = 0
        if let tableView = self as? UITableView {
            for section in 0 ..< tableView.numberOfSections {
                items += tableView.numberOfRows(inSection: section)
            }
        } else if let collectionView = self as? UICollectionView {
            for section in 0 ..< collectionView.numberOfSections {
                items += collectionView.numberOfItems(inSection: section)
            }
        }
        return items
    }
    
    ///  end refresd and load more
    func endRefreshAndLoadMore() {
        endRefreshing()
        endLoadMore()
    }
}

private var tokenHandler: UInt8 = 0

enum ScrollGuideType: Int {
    case vertical = 0
    case horizontal
}

extension UIScrollView {

    private var observationTkn: NSKeyValueObservation? {
        if let tkn: AnyObject = objc_getAssociatedObject(self, &tokenHandler) as AnyObject? {
            return tkn as? NSKeyValueObservation
        }
        return nil
    }

    /// Implementation guide arrow view for scroll view
    /// Must call remove after use it
    func addArrowIconGuideToSuperView(forScrollType type: ScrollGuideType = .vertical) {

        guard let view = self.superview else { return }
        //init
        let isVertical = type == .vertical
        let upImageView = isVertical ? UIImageView(image: #imageLiteral(resourceName: "iconArrowUp")) : UIImageView(image: #imageLiteral(resourceName: "iconArrowLeft"))
        let downImageView = isVertical ? UIImageView(image: #imageLiteral(resourceName: "iconArrowDown")) : UIImageView(image: #imageLiteral(resourceName: "iconScrollArrowRight"))
        view.addSubview(upImageView)
        view.addSubview(downImageView)
        upImageView.translatesAutoresizingMaskIntoConstraints = false
        downImageView.translatesAutoresizingMaskIntoConstraints = false
        // Constraint up ImageView
        view.addConstraint(NSLayoutConstraint(item: upImageView, attribute: isVertical ? .centerX : .centerY, relatedBy: .equal, toItem: self, attribute: isVertical ? .centerX : .centerY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: upImageView, attribute: isVertical ? .top : .left, relatedBy: .equal, toItem: self, attribute: isVertical ? .top : .left, multiplier: 1.0, constant: 0.0))
        // Constraint down ImageView
        view.addConstraint(NSLayoutConstraint(item: downImageView, attribute: isVertical ? .centerX : .centerY, relatedBy: .equal, toItem: self, attribute: isVertical ? .centerX : .centerY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: downImageView, attribute: isVertical ? .bottom : .right, relatedBy: .equal, toItem: self, attribute: isVertical ? .bottom : .right, multiplier: 1.0, constant: 0.0))
        upImageView.isHidden = true
        downImageView.isHidden = true

        let token = self.observe(\.contentOffset, options: [.new, .old]) { _, _ in
            upImageView.isHidden = true
            downImageView.isHidden = true
            var showUpdownImage = false
            switch type {
            case .vertical:
                if self.contentSize.height > self.frame.size.height {
                    showUpdownImage = true
                }
            case .horizontal:
                if self.contentSize.width > self.frame.size.width {
                    showUpdownImage = true
                }
            }
            if showUpdownImage {
                let yOffset: CGFloat, fullHeight: CGFloat, displayHeight: CGFloat
                if isVertical {
                    yOffset = self.contentOffset.y
                    fullHeight = self.contentSize.height
                    displayHeight = self.bounds.size.height
                } else {
                    yOffset = self.contentOffset.x
                    fullHeight = self.contentSize.width
                    displayHeight = self.bounds.size.width
                }
                if yOffset > 0 {
                    upImageView.isHidden = false
                }
                if yOffset < fullHeight - displayHeight - 6.0 {
                    downImageView.isHidden = false
                }
                if self.contentOffset.y < 0, self.isRefreshing(), (fullHeight - UIScrollView.refreshHeight) <= displayHeight {
                    downImageView.isHidden = true
                }
            }
        }
        objc_setAssociatedObject(self, &tokenHandler, token, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func removeIconGuideObserver() {
        objc_removeAssociatedObjects(self)
        self.observationTkn?.invalidate()
    }
}
// MARK: - Refresh control
extension UIScrollView {
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool = false) {
        if let tableView = self as? UITableView {
            let numberOfSections = tableView.numberOfSections
            for i in 0 ..< numberOfSections {
                if tableView.numberOfRows(inSection: i) > 0 {
                    tableView.scrollToRow(at: IndexPath.init(row: 0, section: i), at: .bottom, animated: animated)
                    break
                }
            }
        } else if let collectionView = self as? UICollectionView {
            let numberOfSections = collectionView.numberOfSections
            for i in 0 ..< numberOfSections {
                if collectionView.numberOfItems(inSection: i) > 0 {
                    collectionView.scrollToItem(at: IndexPath.init(row: 0, section: i), at: .bottom, animated: animated)
                    break
                }
            }
        } else {
            let topOffset = CGPoint(x: 0, y: -contentInset.top)
            setContentOffset(topOffset, animated: animated)
        }
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom(animated: Bool = false) {
        if let tableView = self as? UITableView {
            let numberOfSections = tableView.numberOfSections
            for i in (0 ..< numberOfSections).reversed() {
                let numberOfRows = tableView.numberOfRows(inSection: i)
                if numberOfRows > 0 {
                    tableView.scrollToRow(at: IndexPath.init(row: numberOfRows - 1, section: i), at: .top, animated: animated)
                    break
                }
            }
        } else if let collectionView = self as? UICollectionView {
            let numberOfSections = collectionView.numberOfSections
            for i in (0 ..< numberOfSections).reversed() {
                let numberOfRows = collectionView.numberOfItems(inSection: i)
                if numberOfRows > 0 {
                    collectionView.scrollToItem(at: IndexPath.init(row: numberOfRows - 1, section: i), at: .top, animated: animated)
                    break
                }
            }
        } else {
            let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
            if(bottomOffset.y > 0) {
                setContentOffset(bottomOffset, animated: animated)
            }
        }
    }
}
