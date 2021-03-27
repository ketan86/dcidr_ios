//
//  UserCache.swift
//  dcidr
//
//  Created by John Smith on 12/27/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation

class UserCache {
    func getPref(_ key: String) -> String?{
        let prefDefault = UserDefaults.standard
        if let keyVal = prefDefault.string(forKey: key){
            return keyVal
        }
        return nil
    }
    func updatePref(_ key: String,value: String){
        let prefDefault = UserDefaults.standard
        prefDefault.set(value, forKey: key)
    }
    
    func deletePref(_ key: String) {
        let prefDefault = UserDefaults.standard
        prefDefault.removeObject(forKey: key)
    }
    
    func clear(){
        let prefDefault = UserDefaults.standard
        prefDefault.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}
