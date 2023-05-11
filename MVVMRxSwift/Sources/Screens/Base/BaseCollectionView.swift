//
//  BaseCollectionView.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 11/05/2023.
//

import UIKit

class BaseCollectionView: UICollectionView {
    fileprivate var ___loaded = false // stupid bug
    var autoLoad = true
    var sectionData = 0
    var sectionLoading = 1
    
    var controller: ListControllable!
    var numberOfRowsPerLine: Int = 3
    var isShowLoadMoreIndicator = false
    var loadingView: LoadingAnimation!
    var topRefresher : PullToRefresh?

    var lastContentOffset: CGPoint!
    
    override func viewDidAppear(_ data: Any? = nil) {
        super.viewDidAppear()
        self.dataSource = self
        self.delegate = self
        
//        if self.isScrollEnabled && loadingView == nil {
//            let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 60)
//            loadingView = LoadingAnimation(frame: frame)
//            loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
//            self.addPullToRefreshWithAction({ [weak self] in
//                self?.onRefreshList()
//                }, withAnimator: self, withSubview: loadingView
//            )
//            self.alwaysBounceVertical = true
//        }
        
        if self.isScrollEnabled && topRefresher == nil {
            let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 60)
            loadingView = LoadingAnimation(frame: frame)
            loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
            topRefresher = PullToRefresh(refreshView: loadingView, animator: LoadingViewAnimator(refreshView: loadingView), height: 40, position: .top)
            self.addPullToRefresh(topRefresher!) { [weak self] in
                self?.onRefreshList()
            }
            self.alwaysBounceVertical = true
        }
        
        self.register(UINib.init(nibName: String(describing: LoadingCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: Constant.ViewId.loadingCell)

        if autoLoad {
            getList()
        }
    }

    override func viewDidReappear(_ data: Any? = nil) {
        super.viewDidReappear(data)

        if self.pullToRefreshView?.loading ?? false {
            endRefreshing()
        }

        for controller in controllers {
            controller.isPause = false
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        for controller in controllers {
            controller.isPause = true
        }
    }
    
    func getList() {
        controller.getList()
    }
    
    func getNextList() {
        controller.getNextList()
    }
    
    func createLoadingCell(_ indexPath: IndexPath) -> UICollectionViewCell {
        return self.dequeueReusableCell(withReuseIdentifier: Constant.ViewId.loadingCell, for: indexPath)
    }
    
    @objc func onRefreshList() {
        getList()
        hideLoadMoreIndicator()
    }
    
    override func update(_ command: Command, data: Any?) {
        switch command {
        case controller.startLoadingAnimationCommand:
            beginRefreshing()
        case controller.stopLoadingAnimationCommand:
            //titleLabel.text = chatController.conversationDto.conversation.name
            endRefreshing()
            print("stop loading...")
        case .vShowError:
            if let error = data as? NSError {
                //titleLabel.text = error.localizedDescription
                print(error.localizedDescription)
            }
            endRefreshing()
            self.hideLoadMoreIndicator()
        case controller.updateListCommand:
            self.showItemList()
        case controller.addItemsCommand:
            self.addItems()
        default:
            break
        }
    }

    func beginRefreshing() {
        self.startPullToRefresh()
        self.startRefreshing(at: .top)
    }

    func endRefreshing() {
        self.stopPullToRefresh()
        self.endRefreshing(at: .top)
    }
    
    func showItemList() {
        self.reloadData()
//        self.setContentOffset(CGPoint.zero, animated: true)
        if controller.hasNext {
            showLoadMoreIndicator()
        } else {
            hideLoadMoreIndicator()
        }
    }
    
    func addItems() {
        let start = self.numberOfItems(inSection: sectionData)
        let end = controller.itemCount
        var indexPaths = [IndexPath]()
        for i in start..<end {
            indexPaths.append(IndexPath(row: i, section: sectionData))
        }
        self.insertItems(at: indexPaths)
        if controller.hasNext {
            showLoadMoreIndicator()
        } else {
            hideLoadMoreIndicator()
        }
    }
    
    func showLoadMoreIndicator() {
        isShowLoadMoreIndicator = true
        
        if self.numberOfItems(inSection: sectionLoading) == 0 {
            let indexPath = IndexPath(row: 0, section: sectionLoading)
            self.insertItems(at: [indexPath])
        }
    }
    
    func hideLoadMoreIndicator() {
        isShowLoadMoreIndicator = false
        
        if self.numberOfItems(inSection: sectionLoading) > 0 {
            if ___loaded {
                let indexPath = IndexPath(row: 0, section: sectionLoading)
                self.deleteItems(at: [indexPath])
            }
        }
    }

    deinit {
        releaseControllers()
        removePullToRefresh(at: .top)
    }
}

extension BaseCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == sectionLoading {
            return self.createLoadingCell(indexPath)
        }
        fatalError("Please implement method: cellForRowAt")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ___loaded = true
        switch section {
        case sectionData:
            return controller.itemCount
        case sectionLoading:
            return isShowLoadMoreIndicator ? 1 : 0
        default:
            fatalError("Invallid section.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let loadingCell = cell as? LoadingCollectionViewCell else {
            return
        }
        
        getNextList()
        
        if isShowLoadMoreIndicator {
            loadingCell.startLoading()
        } else {
            loadingCell.endLoading()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyObservers(.vEnableUpdateToolbarsOffset)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset
        let data = [
            Constant.ViewParam.scrollView: scrollView
            ] as [String : Any]
        notifyObservers(.vStartUpdateToolbarsOffset, data: data)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastContentOffset == nil { return }

        if scrollView.contentOffset.y <= 0 {
            notifyObservers(.vShowToolbars)
        } else {
//            if scrollView.contentOffset.y + scrollView.frame.height <= scrollView.contentSize.height {
                let offset = lastContentOffset.y - scrollView.contentOffset.y
                let data = [
                    Constant.ViewParam.offset: offset,
                    Constant.ViewParam.scrollView: scrollView
                    ] as [String : Any]
                notifyObservers(.vUpdateToolbarsOffset, data: data)
//            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if lastContentOffset == nil { return }

        let offset = lastContentOffset.y - scrollView.contentOffset.y
        let data = [
            Constant.ViewParam.offset: offset,
            Constant.ViewParam.scrollView: scrollView
            ] as [String : Any]
        notifyObservers(.vUpdateToolbarsVisibility, data: data)
        lastContentOffset = nil
        if decelerate {
            notifyObservers(.vDisableUpdateToolbarsOffset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

extension BaseCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == sectionLoading {
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
        else {
            let itemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
            let size = (collectionView.bounds.width - itemSpacing * (CGFloat)(self.numberOfRowsPerLine - 1)) / (CGFloat)(self.numberOfRowsPerLine)
            return CGSize(width: size, height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

