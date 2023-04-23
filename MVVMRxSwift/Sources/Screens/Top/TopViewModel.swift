//
//  TopViewModel.swift
//  MVVMRxSwift
//
//  Created by Nguyễn Đức Tân on 22/04/2023.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class TopViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let showSkeleton: Driver<Bool>
        let refreshing: Driver<Bool>
        let error: Driver<Error>
        let dataRelay: Driver<[SectionModel<String, Photo>]>
    }
       
    private var photoAPI: PhotosAPI?
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        let photos = input.trigger.flatMapLatest {
            return APIProvider()
                .makePhotosAPI()
                .fetchPhots()
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let errors = errorTracker.asDriver()
        let fetching = activityIndicator.asDriver()
        let showSkeleton = Driver.combineLatest(fetching, photos.asDriver()) { fetching, photos in
            return fetching && photos.isEmpty
        }
        let models = photos.map { photos in
            return [SectionModel(model: "", items: photos)]
        }.asDriver()
        
        let refreshing = Driver.combineLatest(fetching, photos.asDriver()) { fetching, photos in
            return fetching && !photos.isEmpty
        }
        
        return Output(showSkeleton: showSkeleton,
                      refreshing: refreshing,
                      error: errors,
                      dataRelay: models)
    }
    
}
