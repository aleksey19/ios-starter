//
//  ConfigLoader.swift
//  Quevis
//
//  Created by Aleksey Bidnyk on 28.10.2020.
//  Copyright © 2020 Liquidfish. All rights reserved.
//

import Foundation

class ConfigLoader {
    static let configName = "Config.plist"
    
    static func parseConfig(named fileName: String = configName) -> Configuration {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil),
            let fileData = FileManager.default.contents(atPath: filePath) else {
                fatalError("🚫 Configuration file \(fileName) can't be loaded!")
        }
        
        do {
            let config = try PropertyListDecoder().decode(Configuration.self, from: fileData)
            return config
        } catch {
            fatalError("🚫 Configuration file \(fileName) can't be decoded: \(error)!")
        }
    }
}

struct Configuration: Decodable {
    let config: String
    let apiUrl: String
    let flags: ConfigurationFlags?
}

struct ConfigurationFlags: Decodable {
    let isDevelopment: Bool
    let shouldCacheAllNetworkData: Bool
    let shouldCacheOnlyImages: Bool
}
