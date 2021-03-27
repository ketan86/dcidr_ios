////
////  SmartSearch.swift
////  dcidr
////
////  Created by John Smith on 2/4/17.
////  Copyright © 2017 dcidr. All rights reserved.
////
//
//import Foundation
//
//
//protocol SearchHelper {
//    func onSearchFinish(arrayList: Array<AnyObject>)
//    func onDataFetchFinish(arrayList: Array<AnyObject>)
//    func onDataFetch(searchStr: String, onDataFetchFinishCb: (_ arrayList: Array<AnyObject>) -> Void)
//}
//
//
//protocol Searchable {
//    func getSearchString() -> String
//}
//
//class SmartSearch {
//    fileprivate var mFilteredHashDict: Dictionary<String, Array<AnyObject>>!
//    fileprivate var mSearchedObjectList: Array<AnyObject>!
//    fileprivate var mSearchble: Searchable!
//
//    
//    init(){
//        self.mFilteredHashDict = Dictionary<String, Array<AnyObject>>()
//        self.mSearchedObjectList  = Array<AnyObject>()
//        
//    }
//    
//    
//
//    func search(searchStr: String, searchHelper: SearchHelper){
//        if (searchStr == "") {
//            searchHelper.onSearchFinish(arrayList: self.mSearchedObjectList)
//            return
//        }
//    
//        if(self.mFilteredHashDict[searchStr] != nil){
//            searchHelper.onSearchFinish(arrayList: Array(self.mFilteredHashDict.values) as Array<AnyObject>)
//            return
//        }
//    
//        let searchStrPrefix = searchStr.substring(to: searchStr.index(searchStr.startIndex, offsetBy:  searchStr.characters.count - 1))
//
//        if(self.mFilteredHashDict[searchStrPrefix] != nil){
//            searchHelper.onDataFetch(searchStr: searchStr, onDataFetchFinishCb: {
//                (arrayList: Array<AnyObject>) in
//                self.mFilteredHashDict[searchStr] = Array<AnyObject>(arrayList)
//                self.mSearchedObjectList = self.mFilteredHashDict[searchStr]
//                searchHelper.onSearchFinish(arrayList: Array<AnyObject>(self.mSearchedObjectList))
//
//            })
//        }else {
//            // if search prefix is in found, (if we are searching for ab and if a is there in map) we loop though all the
//            // objects by calling getSearchString (for basegroup, it is a groupName) and match if name matches the search
//            // string. if yes, we add it to arrayList otherwise ignore.
//            self.mSearchedObjectList = mFilteredHashDict[searchStrPrefix]
////            var arrayList = Array<AnyObject>()
////            for obj: AnyObject in self.mSearchedObjectList {
////                let method: Method = class_getInstanceMethod(object_getClass(obj), Selector(("getSearchString:")))
////            }
//                //    String str = null;
////    try {
////    Method method = mSearchedObjList.get(i).getClass().getMethod("getSearchString", new Class<?>[]{});
////    str = (String) method.invoke(mSearchedObjList.get(i));
////    } catch (NoSuchMethodException e) {
////    Log.e("SmartSearch", "Error getting search string");
////    } catch (InvocationTargetException e) {
////    Log.e("SmartSearch", "Error getting search string");
////    } catch (IllegalAccessException e) {
////    Log.e("SmartSearch", "Error getting search string");
////    }
////    //                if(str == null) {
////    //                    Log.e("SmartSearch", "search string null");
////    //                    //onSearchFinishCallback.call(arrayList);
////    //                    //return;
////    //                }else {
////    if(str.toLowerCase().contains(searchStr)){
////    arrayList.add(mSearchedObjList.get(i));
////    }
////    //}
////    }
////    //if(arrayList.size() != 0){
////    filteredHashMap.put(searchStr, arrayList);
////    //}
////    onSearchFinishCallback.onSearchFinish(arrayList);
////    }
////    }
//            
//        }
//}
