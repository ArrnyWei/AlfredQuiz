//
//  PhotoUICollectionView.swift
//  ImgurAPI
//
//  Created by Shih Chi Wei on 2022/5/20.
//

import UIKit
import Combine

class PhotoUICollectionView: UICollectionView {

    typealias Datasource = UICollectionViewDiffableDataSource<Gallery, GalleryImage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Gallery, GalleryImage>

    var scrollToButtomSubject = PassthroughSubject<Void, Never>()

    private var datasource: Datasource!

    private var mode = ViewController.Mode.gallery

    private var galleries: [Gallery] = []

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        register(PhotoCollectionViewCell.self)
        delegate = self
        configureDatasource()
        setCollectionViewLayout(createLayout(), animated: false)
    }

    private func configureDatasource() {
        datasource = Datasource(collectionView: self, cellProvider: { [unowned self] collectionView, indexPath, galleryImage in
            let cell = collectionView.dequeueReusableCell(with: PhotoCollectionViewCell.self, for: indexPath)
            cell.update(galleryImage: galleryImage, mode: mode)
            return cell
        })
    }

    func changeMode(mode: ViewController.Mode) {
        self.mode = mode
        setCollectionViewLayout(createLayout(), animated: true)
        datasource.apply(snapshot(mode: mode), animatingDifferences: true)
        let photoCells = visibleCells.compactMap({ $0 as? PhotoCollectionViewCell })
        photoCells.forEach { (cell) in
            cell.updateMode(mode: mode)
        }
    }

    func addGalleries(galleries: [Gallery], mode: ViewController.Mode) {
        self.galleries.append(contentsOf: galleries)
        self.changeMode(mode: mode)
    }

    private func snapshot(mode: ViewController.Mode = .gallery) -> Snapshot {
        var snapshot = Snapshot()

        snapshot.appendSections(galleries)

        galleries.forEach { gallery in
            if let images = gallery.images {
                if mode == .gallery {
                    if var image = images.first {
                        image.galleryTitle = gallery.title
                        snapshot.appendItems([image], toSection: gallery)
                    }
                } else {
                    snapshot.appendItems(images, toSection: gallery)
                }
            }
        }

        return snapshot
    }

    private func createLayout() -> UICollectionViewLayout {
        if mode == .gallery {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        } else {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1/3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }

    }
}

extension PhotoUICollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if mode == .gallery {
            if indexPath.section == galleries.count - 1 {
                scrollToButtomSubject.send()
            }
        } else {
            if indexPath.section == galleries.count - 1,
               let images = galleries[indexPath.section].images,
               indexPath.count == images.count - 1 {
                scrollToButtomSubject.send()
            }
        }
    }
}
