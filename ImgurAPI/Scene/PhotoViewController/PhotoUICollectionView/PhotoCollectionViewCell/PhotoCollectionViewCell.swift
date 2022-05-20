//
//  PhotoCollectionViewCell.swift
//  ImgurAPI
//
//  Created by Shih Chi Wei on 2022/5/21.
//

import UIKit
import Combine

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    func update(galleryImage: GalleryImage, mode: ViewController.Mode) {
        titleLabel.text = galleryImage.galleryTitle
        imageView.loadImageUsingCache(withUrl: galleryImage.link, contentMode: .scaleAspectFill, dataHandler:  { url ,data, response in
            if galleryImage.link == url {
                response(data)
            }
        })
        contentView.clipsToBounds = true
        updateMode(mode: mode)
    }

    func updateMode(mode: ViewController.Mode) {
        titleLabel.isHidden = mode == .allPhotos
        contentView.layer.cornerRadius = mode == .gallery ? 16 : 0
    }
}
