//
//  Gallery.swift
//  ImgurAPI
//
//  Created by Steven Chen on 2022/4/29.
//

import Foundation

struct Gallery {
        
    var id: String
    var title: String
    var cover: String?
    var coverWidth: Double?
    var coverHeight: Double?
    var link: String
    var datetime: Int
    var ups: Int
    var images: [GalleryImage]?
    var imagesCount: Int?
    var type: String?
    var isAlbum: Bool
    
    func getFirstImageLink() -> String? {
        guard isAlbum else {
            return type == "image/jpeg" ? link : nil
        }
        
        return images?.first(where: { image in
            image.type == "image/jpeg"
        })?.link
    }
}

extension Gallery: Hashable {
    static func == (lhs: Gallery, rhs: Gallery) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Gallery: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case cover
        case coverWidth = "cover_width"
        case coverHeight = "cover_height"
        case link
        case datetime
        case ups
        case images
        case imagesCount = "images_count"
        case type
        case isAlbum = "is_album"
    }
}
