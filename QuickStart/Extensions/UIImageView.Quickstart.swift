//
//  UIImageView.Quickstart.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/19.
//

import UIKit

extension UIImageView {
    /// Loads image with URL, but doesn't cache it.
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
