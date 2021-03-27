//
//  Points.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
class Points {
    fileprivate var mLatitude: Double!
    fileprivate var mLongitude: Double!
    init(lat: Double = 0, long: Double = 0) {
        self.mLatitude = lat
        self.mLongitude = long
    }
    func toString() -> String {
        return "(" + String(mLatitude) + ", " + String(mLongitude) + ")"
    }
    func stringToDoubleArray(_ pointsAsStr: String) -> [Double:Double]{
        var points = [Double:Double]()
        var array: [String] = pointsAsStr.components(separatedBy: ",")
        points[0] = NSString(string: array[0].components(separatedBy: "\\(")[1]).doubleValue
        points[1] = NSString(string: array[0].components(separatedBy: "\\)")[0]).doubleValue
        return points
    }
    func getLatitude() -> Double {
        return self.mLatitude
    }
    func getLongitude() -> Double {
        return self.mLongitude
    }
    
    func setLatitude(_ lat: Double) {
        self.mLatitude = lat
    }
    
    func setLongitude(_ long : Double) {
        self.mLongitude = long
    }
}
