//
//  DropDownViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation
import RxSwift
import RxDataSources
import RxRelay

class DropDownViewModel {
    
    typealias ItemModel = SectionModel<String, String>
    
    private let options: [String]
    private weak var coordinator: SceneCoordinator?
    private(set) var selectedValue: String?
    
    // MARK: - Input
    
    lazy private(set) var itemSelected: PublishSubject<IndexPath> = .init()
    
    // MARK: - Output
    
    lazy private var itemsRelay: BehaviorRelay<[ItemModel]> = .init(value: [])
    var items: Observable<[ItemModel]> {
        itemsRelay.asObservable()
    }
    
    lazy private var selectedOptionSubject: PublishSubject<String?> = .init()
    var selectedOptionObservable: Observable<String> {
        selectedOptionSubject.asObservable().filterNil()
    }
    
    // MARK: - Vars
    
    var selectedIndex: Int? {
        if let selectedValue = selectedValue {
            return options.firstIndex(of: selectedValue)
        }
        return nil
    }

    private let bag = DisposeBag()
        
    // MARK: - Init
    
    init(options: [String],
         coordinator: SceneCoordinator,
         selectedValue: String? = nil) {
        self.options = options
        self.coordinator = coordinator
        self.selectedValue = selectedValue
        
        makeSections()
        listenTriggers()
    }
    
    // MARK: - Make sections
    
    private func makeSections() {
        let section = ItemModel(model: "", items: options)
        itemsRelay.accept([section])
    }
    
    // MARK: - Listen triggers
    
    private func listenTriggers() {
        itemSelected
            .map({ [weak self] indexPath -> String? in
                if indexPath.row < self?.options.count ?? 0 {
                    return self?.options[indexPath.row]
                }
                return nil
            })
            .filterNil()
            .bind(to: selectedOptionSubject)
            .disposed(by: bag)        
    }
}
