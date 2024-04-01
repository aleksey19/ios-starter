//
//  RadioButtonsGroup+Rx.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxCocoa

class RadioButtonsGroupDelegateProxy: DelegateProxy<RadioButtonsGroup, RadioButtonsGroupDelegate>,
                                      DelegateProxyType,
                                      RadioButtonsGroupDelegate {
    init(parentObject: RadioButtonsGroup) {
        super.init(parentObject: parentObject, delegateProxy: RadioButtonsGroupDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RadioButtonsGroupDelegateProxy(parentObject: $0) }
    }
    
    static func currentDelegate(for object: RadioButtonsGroup) -> RadioButtonsGroupDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RadioButtonsGroupDelegate?, to object: RadioButtonsGroup) {
        object.delegate = delegate
    }
    
    // MARK: - RadioButtonsGroupDelegate
    
    func didCheckedButton(at index: Int) {
        didCheckedButtonSubject.onNext(index)
    }
    
    // MARK: - Proxy subject
    
    internal lazy var didCheckedButtonSubject = PublishSubject<Int>()
    
    // MARK: - Completed
    
    deinit {
        didCheckedButtonSubject.onCompleted()
    }
}

extension Reactive where Base: RadioButtonsGroup {

    var didCheckedButton: Observable<Int> {
        return RadioButtonsGroupDelegateProxy
            .proxy(for: base)
            .didCheckedButtonSubject
            .asObservable()
    }
}
