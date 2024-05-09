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
    /// ID for reusable components: UITableViewCell, UICollectionViewCell etc.
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
    
    /// Register cell witn the nib.
    func registerCell(_ nibName: String) {
        self.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
    
    /// Register cell without the nib. In this case cell should be configured in the code.
    func registerCell<T: UITableViewCell>(_ type: T.Type) {
        self.register(T.self, forCellReuseIdentifier: type.reuseID)
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
    
    /// Register cell witn the nib.
    func registerCell(_ nibName: String) {
        self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
    }
    
    /// Register cell without the nib. In this case cell should be configured in the code.
    func registerCell<T: UITableViewCell>(_ type: T.Type) {
        self.register(T.self, forCellWithReuseIdentifier: T.reuseID)
    }
    
    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else {
            fatalError("🚫 Can't dequeue collection view cell with such type")
        }
        return cell
    }
}
