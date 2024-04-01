//
//  UITextField+Rx.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

#if os(iOS) || os(tvOS)

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UITextField {
    /// Reactive wrapper for `isFirstResponder` property.
    public var isFirstResponder: ControlProperty<Bool> {
        return base.rx.controlPropertyWithDefaultEvents(
            getter: { textField in
                textField.isFirstResponder
            },
            setter: { textField, value in
                // Setter is unaccessible
            }
        )
    }
    
    /// This is a separate method to better communicate to public consumers that
    /// an `editingEvent` needs to fire for control property to be updated.
    internal func controlPropertyWithDefaultEvents<T>(
        editingEvents: UIControl.Event = [.allEditingEvents, .valueChanged],
        getter: @escaping (Base) -> T,
        setter: @escaping (Base, T) -> Void
        ) -> ControlProperty<T> {
        return controlProperty(
            editingEvents: editingEvents,
            getter: getter,
            setter: setter
        )
    }
}

#endif
