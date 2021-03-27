//
//  FetchManager.swift
//  dcidr
//
//  Created by John Smith on 12/29/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
class FetchManager {
    fileprivate var mStartIndex: Int = 0
    fileprivate var mEndIndex: Int = 0
    fileprivate var mMinGap: Int = 0
    fileprivate var mMaxGap: Int = 0
    fileprivate var mPreviousVisibleEndIndex: Int = 0
    fileprivate var mPreviousEndIndex: Int = 0
    
    init(minGap: Int, maxGap:Int) {
        self.mMinGap = minGap
        self.mMaxGap = maxGap
        self.mStartIndex = 0
        self.mEndIndex = 0
        self.mPreviousVisibleEndIndex = -1
        self.mPreviousEndIndex = -1
    }
    
    init(minGap: Int, maxGap:Int,startIndex: Int, endIndex: Int) {
        self.mMinGap = minGap
        self.mMaxGap = maxGap
        self.mStartIndex = startIndex
        self.mEndIndex = endIndex
    }
    
    func reset() {
        self.mStartIndex = 0
        self.mEndIndex = 0
        self.mPreviousVisibleEndIndex = -1
        self.mPreviousEndIndex = -1

    }
    
    func incrMinGap(_ value: Int) {
        self.mMinGap += value
    }
    
    func getMinGap() -> Int {
        return self.mMinGap
    }
    
    func getEndIndex() -> Int {
        return self.mEndIndex
    }
    
    func setEndIndex(_ endIndex: Int) {
        self.mEndIndex = endIndex
    }
    
    func incrementEndIndex(_ value: Int) {
        self.mEndIndex += value
    }
    
    func fetch(_ visibleStartIndex: Int, visibleEndIndex: Int, fetchManagerCb: (_ offset:Int, _ limit:Int) -> ()){
       if(self.mEndIndex == 0){
            self.mEndIndex = visibleEndIndex + self.mMinGap;
            fetchManagerCb(visibleStartIndex, self.mEndIndex)
        }else {
            if((self.mEndIndex - visibleEndIndex) < 0 ) {
                return;
            }
            if (visibleEndIndex - self.mPreviousVisibleEndIndex <= 0) {
                //we are scrolling backwards or not scrolling at all.
                if (self.mEndIndex == self.mPreviousEndIndex) {
                    //the EndIndex is same as previous End Index, so no new data has to be added
                    //Log.i("Ketan", "Mgr: Not fetching, as prevVisible = " + previousVisibleEnd + ", visibleEnd = " + visibleEndIndex);
                    return;
                }
            }
            if((self.mEndIndex - visibleEndIndex) <= self.mMinGap ) {
                //Log.i("Ketan", "Mgr: mMinGap = " + mMinGap + ", mEndIndex = " + mEndIndex + ", mPrevEndIndex = "+ mPreviousEndIndex + ", mPrevVisibleEndIndex = " + mPreviousVisibleEndIndex+"visibleEndIndex = " + visibleEndIndex + ", fetching...");
                fetchManagerCb(self.mEndIndex, self.mMinGap)
                self.mPreviousEndIndex = self.mEndIndex;
            }
        }
        self.mPreviousVisibleEndIndex = visibleEndIndex;
    }
}
