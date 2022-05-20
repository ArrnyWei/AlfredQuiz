//
//  GallerySearchResult.swift
//  ImgurAPI
//
//  Created by Steven Chen on 2022/4/29.
//

import Foundation

// https://api.imgur.com/models/basic
struct GallerySearchResult {
        
    var galleries: [Gallery]
    var success: Bool
    var status: Int
}

extension GallerySearchResult: Decodable {

    enum CodingKeys: String, CodingKey {
        case galleries = "data"
        case success
        case status
    }
}
