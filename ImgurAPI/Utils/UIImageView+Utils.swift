//
//  UIImageView+Utils.swift
//  ecogenie
//
//  Created by Shih Chi Wei on 2022/5/21.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCache(withUrl urlString: String,
                             contentMode: UIView.ContentMode = .scaleAspectFit,
                             onFailure: ((Error) -> Void)? = nil,
                             needActivityIndicator: Bool = true,
                             dataHandler: ((String, Data, @escaping (Data?) -> Void) -> Void)? = nil) {
        guard let url = URL(string: urlString) else { return }

        self.image = nil
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            self.contentMode = contentMode
            self.backgroundColor = .clear
            return
        }

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        activityIndicator.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        activityIndicator.isHidden = !needActivityIndicator

        // if not, download image from url
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            ensureInMainQueue {
                activityIndicator.removeFromSuperview()
            }
            if error != nil {
                if onFailure != nil {
                    onFailure!(error!)
                }
                return
            }

            func render (with data: Data) {
                ensureInMainQueue {
                    if let image = UIImage(data: data) {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self.image = image
                        self.contentMode = contentMode
                        self.backgroundColor = .clear
                    }
                }
            }
            if let handler = dataHandler {
                handler(urlString ,data!) {
                    guard let processedData = $0 else { return }
                    render(with: processedData)
                }
            } else {
                render(with: data!)
            }
        }).resume()
    }
}
