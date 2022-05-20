//
//  ViewController.swift
//  ImgurAPI
//
//  Created by Steven Chen on 2022/4/28.
//

import UIKit
import Combine

class ViewController: UIViewController {

    lazy var viewModel: ViewModel = {
        return ViewModel()
    }()

    private var cancellables: Set<AnyCancellable> = []
    private var mode = Mode.gallery
    @IBOutlet weak var photoUICollectionView: PhotoUICollectionView!

    private var loadingInProgress = true

    enum Mode: Int {
        case gallery
        case allPhotos
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        bindUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchGallery()
    }

    private func bindViewModel() {
        viewModel.gallerySubject
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.loadingInProgress = false
                switch result {
                case .success(let galleries):
                    if let galleries = galleries {
                        self.photoUICollectionView.addGalleries(galleries: galleries, mode: self.mode)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                case .none:
                    break
                }
            }.store(in: &cancellables)
    }

    private func bindUI() {
        photoUICollectionView.scrollToButtomSubject.sink { [unowned self] _ in
            guard !self.loadingInProgress else { return }
            guard self.viewModel.pageNumber <= 5 else { return }
            loadingInProgress = true
            self.viewModel.fetchGallery()
        }.store(in: &cancellables)
    }

    @IBAction func showModeChange(_ sender: UISegmentedControl) {
        mode = Mode(rawValue: sender.selectedSegmentIndex)!
        photoUICollectionView.changeMode(mode: mode)
    }
}
