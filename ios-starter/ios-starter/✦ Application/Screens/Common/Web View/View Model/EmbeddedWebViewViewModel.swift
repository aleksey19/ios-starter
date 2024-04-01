//
//  EmbeddedWebViewViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class EmbeddedWebViewViewModel: EmbeddedWebViewViewModelCompatible {
    private(set) var url: URL
    
    init(url: URL) {
        self.url = url
    }
}
