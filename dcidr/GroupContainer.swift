//
//  GroupContainer.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class GroupContainer {
    fileprivate var mBaseGroupWrapperDict: Dictionary<Int64, BaseGroupWrapper>!
    fileprivate var mBaseGroupList: Array<BaseGroup>!
    fileprivate var mGroupContainerEventList: Array<BaseEvent>!
    
    fileprivate var mGroupSortKey: BaseGroup.GroupSortKey!
    init(){
        self.mBaseGroupWrapperDict = Dictionary<Int64, BaseGroupWrapper>()
        self.mBaseGroupList = Array<BaseGroup>()
        self.mGroupContainerEventList = Array<BaseEvent>()
        self.mGroupSortKey = BaseGroup.GroupSortKey.GROUP_LAST_MODIFIED_TIME
    }
    
    enum TypeOfResult {
        case SEARCHED, SCROLLED, ALL
    }
    
    fileprivate class BaseGroupWrapper {
        fileprivate var mIsSearchedResult : Bool = false
        fileprivate var  mBaseGroup: BaseGroup!
        
        required init(baseGroup: BaseGroup){
            self.mBaseGroup = baseGroup
        }
        func setIsSearchedResult(_ isSearchedResult: Bool){
            self.mIsSearchedResult = isSearchedResult
        }
        func getIsSearchedResult() -> Bool {
            return self.mIsSearchedResult
        }
        
        func getBaseGroup() -> BaseGroup {
            return mBaseGroup
        }
        
    }
    func populateGroup(_ jsonGroupArray: JSON) {
        if let jsonGroups = jsonGroupArray.array {
            for jsonGroup in jsonGroups {
                if(self.mBaseGroupWrapperDict[jsonGroup["groupId"].int64Value] != nil){
                    self.mBaseGroupWrapperDict[jsonGroup["groupId"].int64Value]!.getBaseGroup().populateMe(jsonGroup)
                    continue
                }
                let baseGroup: BaseGroup = BaseGroup()
                baseGroup.setGroupSortKey(self.mGroupSortKey);
                //baseGroup.getEventContainer().setSortKey(mEventSortKey);
                //baseGroup.getEventContainer().setBaseGroup(baseGroup);
                baseGroup.populateMe(jsonGroup)
                
                let baseGroupWrapper = BaseGroupWrapper(baseGroup: baseGroup)
                baseGroupWrapper.setIsSearchedResult(false)
                self.mBaseGroupWrapperDict[baseGroupWrapper.getBaseGroup().groupId] =  baseGroupWrapper
            }
        }else {
            print("error parsing json")
        }
    }
        
    func setGroupSortKey(key: BaseGroup.GroupSortKey) {
        self.mGroupSortKey = key
    }
    
    func populateGroup(_ baseGroup: BaseGroup, isSearchedResult: Bool){
        let baseGroupWrapper = BaseGroupWrapper(baseGroup: baseGroup)
        baseGroupWrapper.setIsSearchedResult(isSearchedResult)
        self.mBaseGroupWrapperDict[baseGroupWrapper.getBaseGroup().groupId] = baseGroupWrapper
    }
    
    
    func populateGroups(_ arrayList: Array<BaseGroup>, isSearchedResult: Bool){
        for baseGroup in arrayList {
            if(isSearchedResult) {
                // if results are coming as a searched results, we do not want to override the existing baseGroup in mBaseGroupWrapperMap
                // because doing so will set that baseGroup as SEARCHED group and it will destroy the SCROLL state
                if(self.mBaseGroupWrapperDict[baseGroup.groupId] == nil) {
                    let baseGroupWrapper = BaseGroupWrapper(baseGroup: baseGroup)
                    baseGroupWrapper.setIsSearchedResult(isSearchedResult)
                    self.mBaseGroupWrapperDict[baseGroupWrapper.getBaseGroup().groupId] = baseGroupWrapper
                }
            }else {
                let baseGroupWrapper = BaseGroupWrapper(baseGroup: baseGroup)
                baseGroupWrapper.setIsSearchedResult(isSearchedResult)
                self.mBaseGroupWrapperDict[baseGroupWrapper.getBaseGroup().groupId] = baseGroupWrapper
            }
        }
    }
    
    
    func getBaseGroup(_ groupId: Int64) -> BaseGroup? {
        if (self.mBaseGroupWrapperDict[groupId] == nil) {
            return nil
        } else {
            return self.mBaseGroupWrapperDict[groupId]!.getBaseGroup()
        }
    }
    
    func deleteGroups(_ typeOfResult: TypeOfResult){
        for baseGroupWrapper in self.mBaseGroupWrapperDict.values {
            if(typeOfResult == TypeOfResult.SEARCHED) {
                if (baseGroupWrapper.getIsSearchedResult()) {
                    self.mBaseGroupWrapperDict.removeValue(forKey: baseGroupWrapper.getBaseGroup().groupId)
                }
            }else if(typeOfResult == TypeOfResult.SCROLLED){
                if(!baseGroupWrapper.getIsSearchedResult()){
                    self.mBaseGroupWrapperDict.removeValue(forKey: baseGroupWrapper.getBaseGroup().groupId)
                }
            }else {
                self.mBaseGroupWrapperDict.removeValue(forKey: baseGroupWrapper.getBaseGroup().groupId)
            }
        }
    }

    func getGroupContainerEventList(_ typeOfResult: EventContainer.TypeOfResult) -> Array<BaseEvent> {
        //iterate through the mGroupList , each of which is a BaseGroup object, which
        //contains EventContainer which contains events
        self.mGroupContainerEventList.removeAll()
        for baseGroupWrapper in self.mBaseGroupWrapperDict.values {
            self.mGroupContainerEventList.append(contentsOf: baseGroupWrapper.getBaseGroup().getEventContainer().getEventList(typeOfResult))
        }
        self.mGroupContainerEventList.sort(by: >)
        return mGroupContainerEventList;
    }
    
    func refreshGroupContainerEventList(_ typeOfResult: EventContainer.TypeOfResult){
        self.getGroupContainerEventList(typeOfResult)
    }
    
    func getGroupCount() -> Int {
        return self.mBaseGroupWrapperDict.count
    }
    func getGroupIds() -> Array<Int64> {
        print(Array(self.mBaseGroupWrapperDict.keys))
        return Array(self.mBaseGroupWrapperDict.keys)
    }
    
    func removeGroup(_ baseGroup: BaseGroup) {
        self.mBaseGroupWrapperDict.removeValue(forKey: baseGroup.groupId)
    }

    func getGroupList(_ typeOfResult: TypeOfResult) -> Array<BaseGroup> {
        self.refreshGroupList(typeOfResult)
        return self.mBaseGroupList
    }
    
    func refreshGroupList(_ typeOfResult: TypeOfResult){
        self.mBaseGroupList.removeAll()
        let baseGroupWrapperList = Array<BaseGroupWrapper>(self.mBaseGroupWrapperDict.values)
        
        var arrayList =  Array<BaseGroup>()
        for baseGroupWrapper in baseGroupWrapperList {
            if(typeOfResult == TypeOfResult.SEARCHED) {
                if (baseGroupWrapper.getIsSearchedResult()) {
                    arrayList.append(baseGroupWrapper.getBaseGroup())
                }
            }else if(typeOfResult == TypeOfResult.SCROLLED){
                if(!baseGroupWrapper.getIsSearchedResult()){
                    arrayList.append(baseGroupWrapper.getBaseGroup())
                }
            }else {
                arrayList.append(baseGroupWrapper.getBaseGroup())
            }
        }
        arrayList.sort(by: >)
        self.mBaseGroupList.append(contentsOf: arrayList)
    }
    
    func clearGroupDict(){
        self.mBaseGroupWrapperDict.removeAll()
    }

    func clear(){
        self.mBaseGroupList.removeAll()
        self.clearGroupDict()
    }
}
