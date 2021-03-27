//
//  ChweetContainer.swift
//  dcidr
//
//  Created by John Smith on 1/22/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class ChweetContainer {
    fileprivate var mChweetList: Array<Chweet>!
    fileprivate var mChweetDict: Dictionary<Int64, Chweet>!
    //fileprivate HashDict<Long, Integer> mUserChweetColorDict;
    
    init(){
        self.mChweetList = Array<Chweet>();
        self.mChweetDict =  Dictionary<Int64,Chweet>()
        //this.mUserChweetColorDict = new HashDict<Long,Integer>();
    }
    
    func populateMe(_ jsonChweetArray: JSON) {
        if let jsonChweets = jsonChweetArray.array {
            for jsonChweet in jsonChweets {
                
                if(self.mChweetDict[jsonChweet["chweetId"].int64Value] != nil){
                    let c = self.mChweetDict[jsonChweet["chweetId"].int64Value]
                    c?.populateMe(jsonChweet)
                    continue
                }else {
                    let c = Chweet()
                    c.populateMe(jsonChweet);
                    self.mChweetDict[c.getChweetId()] = c
                }
            }
        }else {
            print("error parsing json")
        }
    }

    func refreshChweetList(){
        self.mChweetList.removeAll()
        var arrayList: Array<Chweet> = Array<Chweet>(self.mChweetDict.values)
        arrayList.sort(by: >)
        self.mChweetList.append(contentsOf: arrayList)
        
    }
    
    
    func addChweet(_ c: Chweet) {
        self.mChweetDict[c.getChweetId()] = c
    }
    
    func getChweetDict() -> Dictionary<Int64,Chweet>{
        return self.mChweetDict
    }
    
    func getChweetList() ->  Array<Chweet> {
        self.refreshChweetList()
        return self.mChweetList
    }
    
    func clear(){
        for chweet in self.mChweetList {
            chweet.releaseMemory()
        }
        self.mChweetList.removeAll()
        self.mChweetDict.removeAll()
    }
}
