//
//  GalleryAlbumImage.swift
//  ImgurAPI
//
//  Created by Steven Chen on 2022/4/29.
//

import Foundation

struct GalleryImage: Decodable {
    
    var id: String
    var title: String?
    var width: Double
    var height: Double
    var type: String
    var link: String
    var galleryTitle: String?
}

extension GalleryImage: Hashable {
    static func == (lhs: GalleryImage, rhs: GalleryImage) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
