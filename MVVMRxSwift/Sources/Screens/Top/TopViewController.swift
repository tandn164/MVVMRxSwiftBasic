//
//  TopViewController.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TopViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    private lazy var dataSource = collectionViewDataSource()
    
    private var viewModel: TopViewModel?
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewType = .top
        viewModel = TopViewModel()
        setupCollectionView()
        
        view.isSkeletonable = true
        showSkeleton()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let pull = (collectionView.refreshControl ?? UIRefreshControl()).rx
            .controlEvent(.valueChanged)
            .asDriver()
        
        let input = TopViewModel.Input(trigger: Driver.merge(viewWillAppear, pull),
                                       selectionItem: collectionView.rx.itemSelected.asDriver())
        let output = viewModel?.transform(input: input)
        
        output?.showSkeleton.drive(onNext: { [weak self] showSkeleton in
            if showSkeleton {
                self?.showSkeleton()
            } else {
                self?.hideSkeleton()
            }
        }).disposed(by: disposeBag)
        
        output?.refreshing.drive((collectionView.refreshControl ?? UIRefreshControl()).rx.isRefreshing).disposed(by: disposeBag)
        
        output?.dataRelay.drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        output?.error.drive(onNext: { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }).disposed(by: disposeBag)

        output?.selectedPhoto.drive(onNext: { photo in
            print("Selected Photo: ", photo)
        }).disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        collectionView.isSkeletonable = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        
        let layout = BouncyLayout()
        collectionView.collectionViewLayout = layout
        collectionView.refreshControl = UIRefreshControl()
        
        collectionView.registerCellByNib(PhotoCollectionViewCell.self)
    }
    
    private func showSkeleton() {
        collectionView.prepareSkeleton(completion: { done in
            self.view.showAnimatedGradientSkeleton()
        })
    }
    
    private func hideSkeleton() {
        self.view.hideSkeleton()
    }

    private func collectionViewDataSource() -> RxCollectionViewSkeletonedReloadDataSource<SectionModel<String, Photo>>  {
        return RxCollectionViewSkeletonedReloadDataSource(configureCell: { (dataSource, collectionView, indexPath, item) in
            guard let cell = collectionView.dequeueCell(PhotoCollectionViewCell.self, forIndexPath: indexPath) else {
                return UICollectionViewCell()
            }
            cell.imageView.setImage(withPath: item.downloadURL)
            return cell
        }, reuseIdentifierForItemAtIndexPath: { _, _, _ in
            return PhotoCollectionViewCell.identifier
        })
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
