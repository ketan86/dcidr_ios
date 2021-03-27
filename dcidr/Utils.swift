//
//  Utils.swift
//  dcidr
//
//  Created by John Smith on 12/27/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    static func currentTimeMillis() -> Int64 {
        return Int64((Date().timeIntervalSince1970)*1000)
    }
    
    static func convertImageToBase64(image: UIImage) -> String {
        
        let imageData = UIImagePNGRepresentation(image)
        return imageData!.base64EncodedString(options: .lineLength64Characters)
        
    }
    
    static func convertDateTimeToEpoch(date: String, time: String, timeZone: TimeZone, format: String) -> Int64 {
        let str = date + " " + time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: str)
        return Int64(date!.timeIntervalSince1970 * 1000)
    }

    
    static func convertBase64ToImage(base64String: String) -> UIImage {
        return UIImage(data: Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!)!
        
    }// end convertBase64To
    
    static func epochToDate(epoch: Int64) -> String {
        let dateFormatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(epoch / 1000))
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdYYYY") // set template after setting locale
        return dateFormatter.string(from: date) // Jan 2, 2001
    }
    
    static func epochToDateFromatted(epoch: Int64, format: String) -> String {
        let dateFormatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(epoch / 1000))
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate(format) // set template after setting locale
        return dateFormatter.string(from: date) // Jan 2, 2001
    }
    
    static func convertDateToMeaningfulText(epochTimeinMilliSecs: Int64, future: Bool) -> String{
        var returnDateStr: String = ""
        if (future) {
            let millisUntilFinished: Int64 = epochTimeinMilliSecs - currentTimeMillis()
            if (millisUntilFinished <= 0) {
                return "EXPIRED"
            }
            let diffSeconds: Int64 = millisUntilFinished / 1000 % 60
            let diffMinutes: Int64 = millisUntilFinished / (60 * 1000) % 60
            let diffHours: Int64 = millisUntilFinished / (60 * 60 * 1000) % 24
            let diffDays: Int64 = millisUntilFinished / (24 * 60 * 60 * 1000)
            
            if (diffSeconds != 0) {
                returnDateStr = String(diffSeconds) + " Secs left"
            }
            if (diffMinutes != 0) {
                returnDateStr = String(diffMinutes) + " Mins left"
            }
            if (diffHours != 0) {
                returnDateStr = String(diffHours) + " Hrs left"
            }
            if (diffDays != 0) {
                returnDateStr = String(diffDays) + " Days left"
            }
            return returnDateStr;
        } else {
            let millisSinceLastUpdated = currentTimeMillis() - epochTimeinMilliSecs;
            if (millisSinceLastUpdated < 1000) {
                //"UPDATED IN THE FUTURE !!";
                return "0 Secs ago";
            }
            let diffSeconds : Int64 = millisSinceLastUpdated / 1000 % 60
            let diffMinutes : Int64 = millisSinceLastUpdated / (60 * 1000) % 60
            let diffHours: Int64 = millisSinceLastUpdated / (60 * 60 * 1000) % 24
            let diffDays:Int64 = millisSinceLastUpdated / (24 * 60 * 60 * 1000)
            
            if (diffSeconds != 0) {
                returnDateStr = String(diffSeconds) + " Secs ago"
            }
            if (diffMinutes != 0) {
                returnDateStr = String(diffMinutes) + " Mins ago"
            }
            if (diffHours != 0) {
                returnDateStr = String(diffHours) + " Hrs ago"
            }
            if (diffDays != 0) {
                returnDateStr = String(diffDays) + " Days ago"
            }
            return returnDateStr;
            }
    }

}
