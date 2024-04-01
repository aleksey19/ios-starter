//
//  RTL.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

var isRTL: Bool {
    NSLocale.characterDirection(forLanguage: NSLocale.preferredLanguages[0]) == NSLocale.LanguageDirection.rightToLeft
}
