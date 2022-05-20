//
//  ViewModel.swift
//  ImgurAPI
//
//  Created by Shih Chi Wei on 2022/5/20.
//

import Foundation
import Combine

class ViewModel {
    lazy var imgurAPI: ImgurAPI = {
        return ImgurAPI()
    }()

    private var cancellable = Set<AnyCancellable>()
    let gallerySubject = CurrentValueSubject<Result<[Gallery]?, Error>?, Never>(nil)
    var pageNumber = 0

    func fetchGallery() {
        pageNumber += 1
        imgurAPI.searchGallery(query: "cats", page: pageNumber)
            .receive(on: RunLoop.main)
            .sink { error in
                print("completed")
            } receiveValue: { [weak self] galleries in
                guard let self = self else { return }
                self.gallerySubject.send(.success(galleries))
            }.store(in: &cancellable)
    }
}
