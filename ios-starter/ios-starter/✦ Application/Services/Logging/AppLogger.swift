//
//  AppLogger.swift
//  Image Genarator
//
//  Created by Aleksey Bidnyk on 25.03.2024.
//

import Foundation

final class AppLogger {
    
    enum Event {
        case signIn
        case signUp
        case signOut
        
        var description: String {
            switch self {
                
            case .signIn:
                return "Sign in"
                
            case .signUp:
                return "Sign up"
                
            case .signOut:
                return "Sign out"
            }
        }
    }
    
    static let shared = AppLogger()
    
    func updateAttributes() {
        
    }
    
    func log(event: Event) {
        log(info: event.description)
    }
}

extension AppLogger: Logable {
    
    func log(error: Error) {
        debugPrint("🚫 Error: \(error)")
    }
    
    func log(info: String) {
        debugPrint("🗒 Info: \(info)")
    }
    
    func log(warning: String) {
        debugPrint("⚠️ Info: \(warning)")
    }
}
