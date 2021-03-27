//: Playground - noun: a place where people can play

import UIKit
import Foundation

enum EventType: Int {
    case UNKNOWN = -1
    case HIKE = 15
    case FOOD = 16
    case SPORT = 17
    case BIRTHDAY = 18
    case HAPPYHOUR = 19
    case POTLUCK = 20
    case VALENTINE = 21
    case BABYSHOWER = 22
    case CHRISTMAS = 23
    case THANKSGIVING = 24;
    
    static func enumFromString(_ str:String) -> EventType? {
        var i = 15
        while let item = EventType(rawValue: i) {
            print("item  \(String(describing: item))")
            print("string \(str.uppercased())")
            if String(describing: item) == str.uppercased() {
                return item
            }
            i += 1
        }
        
        return nil
    }
}

print("hi:")
print(EventType.enumFromString("Hike") ?? "sdsdf")