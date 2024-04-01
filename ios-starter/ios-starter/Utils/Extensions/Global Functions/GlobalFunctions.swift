//
//  GlobalFunctions.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

func executeOnMainThread(_ block: @escaping (() -> Void)) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async { block() }
    }
}

func durationStringFor(_ durationInSeconds: Int) -> String {
    let minutes = Int(durationInSeconds) / 60
    let seconds = durationInSeconds - minutes * 60
    
    var secondsString = "\(seconds)"
    if seconds < 10 {
        secondsString = "0\(seconds)"
    }
    
    return "\(minutes):\(secondsString)"
}
