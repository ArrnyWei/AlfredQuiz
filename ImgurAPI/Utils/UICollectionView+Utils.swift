//
//  UITableView+Utils.swift
//  MVVMSample
//
//  Created by Shih Chi Wei on 2022/5/21.
//

import UIKit

extension UICollectionView {

    public func register<Cell: UICollectionViewCell>(_ cellType: Cell.Type) {
        let nibName = String(describing: cellType)
        if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
            register(UINib(nibName: nibName, bundle: .main), forCellWithReuseIdentifier: nibName)
        } else {
            register(cellType, forCellWithReuseIdentifier: nibName)

        }
    }

    public func dequeueReusableCell<Cell: UICollectionViewCell>(with cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withReuseIdentifier: String(describing: cellType), for: indexPath) as! Cell
    }
}
