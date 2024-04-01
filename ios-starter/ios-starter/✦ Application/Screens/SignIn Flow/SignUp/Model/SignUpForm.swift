//
//  SignUpForm.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

class SignUpForm: InputForm<SignUpFieldType, SignUpFieldViewModel> {
    
    func createRegistrationDataObject() -> AppRestBackend.SignUpParameters {
        var name: String = ""
        var address: String = ""
        var address2: String = ""
        var city: String = ""
        var state: String = ""
        var zip: String = ""
        var accountType: Int = 0
        var phone: String = ""

        for viewModel in viewModels {
            switch viewModel.type {
            case .fullName:
                name = viewModel.value ?? ""
            case .address:
                address = viewModel.value ?? ""
            case .address2:
                address2 = viewModel.value ?? ""
            case .city:
                city = viewModel.value ?? ""
            case .stateAndZip:
                if let vm = viewModel as? StateAndZipSignUpFieldViewModel {
                    state = vm.stateViewModel.value ?? ""
                    zip = vm.zipViewModel.value ?? ""
                }
            case .accountType:
                accountType = (viewModel as? InputFieldRadioButtonViewModelCompatible)?.selectedValueIndex ?? 0
            case .phone:
                // Remove mask from phone to avoid error from api
                phone = (viewModel.value ?? "").withMask(mask: "")
            default:
                break
            }
        }

        return AppRestBackend.SignUpParameters(email: "",
                                               fullName: name,
                                               address1: address,
                                               address2: address2,
                                               city: city,
                                               state: state,
                                               zip: zip,
                                               accountType: accountType,
                                               phoneNumber: phone)
    }
    
    func value(for type: SignUpFieldType) -> String? {
        if let viewModel = viewModels.first(where: { $0.type == type }) {
            return viewModel.value
        }
        return nil
    }
}
