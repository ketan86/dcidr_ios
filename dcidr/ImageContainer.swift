//
//  ImageContainer.swift
//  dcidr
//
//  Created by John Smith on 2/21/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class ImageContainer {
    
    fileprivate var mImageList: Array<ImageViewer>!
    fileprivate var mImageViewerDict: Dictionary<String, ImageViewer>!
    
    init() {
        self.mImageList = Array<ImageViewer>()
        self.mImageViewerDict = Dictionary<String,ImageViewer>()
    }
    
    
    
    func populateMe(_ jsonImage: JSON) {
        let imageViewer = ImageViewer()
        imageViewer.populateMe(jsonImage)
        self.mImageViewerDict[imageViewer.getImageServerUrl()] = imageViewer
    }
    
    func add(url : String, imageViewer: ImageViewer) {
        self.mImageViewerDict[url] = imageViewer
    }
    func get(url: String) -> ImageViewer {
        return self.mImageViewerDict[url]!
    }
    func refreshImageViewerList(){
        mImageList.removeAll()
        var arrayList =  Array<ImageViewer>(self.mImageViewerDict.values)
        arrayList.sort(by: >)
        self.mImageList.append(contentsOf: arrayList)
    }
    
    func getImageViewerDict() -> Dictionary<String, ImageViewer>{
        return self.mImageViewerDict;
    }
    
    func getImageViewerList() -> Array<ImageViewer>{
        self.refreshImageViewerList()
        return self.mImageList
    }
    
//    public ArrayList<String> getImageUris(){
//        ArrayList<String> arrayList = new ArrayList<>();
//        for(ImageViewer imageViewer : mImageViewerMap.values()){
//        arrayList.add(imageViewer.getImageLocalUrl().toString());
//        }
//        return arrayList;
//    }
    
    
    func clear(){
        self.mImageList.removeAll()
        self.mImageViewerDict.removeAll()
    }
}
