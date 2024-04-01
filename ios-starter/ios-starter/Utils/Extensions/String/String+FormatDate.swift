//
//  String+ServerDate.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

extension Date {
    var ISOFormatDate: String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]

        return formatter.string(from: self)
    }

    var yyyyMMddFormatDate: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.string(from: self)
    }
    
    var MMyyyyFormatDate: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy"

        return dateFormatter.string(from: self)
    }

    var yyyyMMddhhmmFormatDate: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"

        return dateFormatter.string(from: self)
    }
}

extension String {
    var ISOFormatDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]

        return formatter.date(from: self)
    }

    var yyyyMMddFormatDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.date(from: self)
    }
}

extension Date {
    
    func timeStringTillNow() -> String {
        let seconds = Int(self.distance(to: Date()))
        
        let days = seconds / 87840
        guard days < 1 else {
            return days > 1 ? "\(days) days" : "\(days) day"
        }
        
        let hours = seconds / 3660
        guard hours < 1 else {
            return hours > 1 ? "\(hours) hours" : "\(hours) hour"
        }
        
        let minutes = seconds / 60
        guard minutes < 1 else {
            return minutes > 1 ? "\(minutes) minutes" : "\(minutes) minute"
        }
                
        guard seconds < 1 else {
            return seconds > 1 ? "\(seconds) seconds" : "\(seconds) second"
        }
        
        return "1 second"
    }
}
