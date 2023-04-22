//
//  TopViewController.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import UIKit
import RxSwift
import RxDataSources
import BouncyLayout

class TopViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    private lazy var dataSource = collectionViewSkeletonedReloadDataSource()
    
    private var model: TopViewModel?
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewType = .top
        model = TopViewModel(view: self)
        setupCollectionView()
        
        view.isSkeletonable = true
        showSkeleton()
    }
    
    private func setupCollectionView() {
        collectionView.isSkeletonable = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        
        let layout = BouncyLayout()
        collectionView.collectionViewLayout = layout
        
        collectionView.registerCellByNib(PhotoCollectionViewCell.self)
    }
    
    private func showSkeleton() {
        collectionView.prepareSkeleton(completion: { done in
            self.view.showAnimatedGradientSkeleton()
            self.model?.performGetPhotos()
        })
    }

    private func collectionViewSkeletonedReloadDataSource() -> RxCollectionViewSkeletonedReloadDataSource<SectionModel<String, Photo>>  {
        return RxCollectionViewSkeletonedReloadDataSource(configureCell: { (ds, cv, ip, item) in
            guard let cell = cv.dequeueCell(PhotoCollectionViewCell.self, forIndexPath: ip) else {
                return UICollectionViewCell()
            }
            cell.imageView.setImage(withPath: item.downloadURL)
            return cell
        }, reuseIdentifierForItemAtIndexPath: { _, _, _ in
            return PhotoCollectionViewCell.identifier
        })
    }
}

extension TopViewController: TopViewModelOutput {
    func photosDidGetSuccess() {
        ApplicationUtil.delay(seconds: 3) { [weak self] in
            guard let self = self else {
                return
            }
            let sections = [SectionModel(model: "", items: self.model?.photos ?? [])]
            
            Observable.just(sections)
                .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
                .disposed(by: self.disposeBag)
            self.view.hideSkeleton()
        }
    }
    
    func photosDidGetFailed(_ error: Error) {
        showAlert(message: error.localizedDescription)
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 15)/2, height: 120)
    }
}
