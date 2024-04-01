//
//  Reusable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

protocol Reusable {
    static var reuseID: String { get }
}

extension Reusable {
    static var reuseID: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable { }
extension UICollectionViewCell: Reusable { }
extension UITableViewHeaderFooterView: Reusable { }

extension UIViewController: Reusable {
    class func instantiateFromNib<T: UIViewController>() -> T {
        return T(nibName: T.reuseID, bundle: nil)
    }
}

extension UITableView {
    
    func registerCells<T: UITableViewCell>(ofTypes cellTypes: [T.Type]) {
        cellTypes.forEach({ registerCell(ofType: $0) })
    }
    
    func registerCell<T: UITableViewCell>(ofType cellType: T.Type) {
        self.register(UINib(nibName: cellType.reuseID, bundle: nil), forCellReuseIdentifier: cellType.reuseID)
    }
    
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(ofType viewType: T.Type) {
        self.register(UINib(nibName: viewType.reuseID, bundle: nil), forHeaderFooterViewReuseIdentifier: viewType.reuseID)
    }
    
    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseID,
                                             for: indexPath) as? T else {
            return cellType.init()
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T>(ofType viewType: T.Type = T.self) -> T where T: UITableViewHeaderFooterView {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseID) as? T else {
            fatalError("🚫 Can't dequeue table view cell with such type")
        }
        return view
    }
}

extension UICollectionView {
    
    func registerCell<T: UICollectionViewCell>(ofType cellType: T.Type) {
        self.register(UINib(nibName: cellType.reuseID, bundle: nil), forCellWithReuseIdentifier: cellType.reuseID)        
    }
    
    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else {
            fatalError("🚫 Can't dequeue collection view cell with such type")
        }
        return cell
    }
}
