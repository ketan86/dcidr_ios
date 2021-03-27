//
//  ImageViewerViewController.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import ImagePicker
class ImageViewerViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, ImagePickerDelegate {
    
    
    @IBOutlet weak var mImageCollectionView: UICollectionView!
    var mGroupId: Int64? = nil
    var mParentEventId: Int64? = nil
    fileprivate let mUserIdStr : String = DcidrApplication.getInstance().getUser().getUserIdStr()
    fileprivate var mImageContainer: ImageContainer!
    
    override func handleInputDataDict(data: [String: Any]?) {
    }
    override func viewDidLoad() {
        self.showUIActivityIndicator()
        self.setUserFetchDoneCb({
            self.initViewController()
            self.stopUIActivityIndicator()
        })
        super.viewDidLoad()
    }
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func initViewController(){
        
        // tell collectionView to use current class for datasource and delegate
        self.mImageCollectionView.delegate = self
        self.mImageCollectionView.dataSource = self

        self.mImageContainer = ImageContainer()
        self.fetchImagesFromSever(visibleStartIndex: 0, visibleEndIndex: 10)
    }
    
   
    
    @IBAction func onImageCaptureButtonClicked(_ sender: UIBarButtonItem) {
        let imagePickerController = ImagePickerController()
        imagePickerController.imageLimit = 1
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        // handle image
        let imageViewer = ImageViewer()
        //imageViewer.setImage(image: images[0])
        imageViewer.setImage(image: UIImage(named: "user_default_icon")!)
        imageViewer.setCreatedByUserName(userName: DcidrApplication.getInstance().getUser().getUserName())
        self.dismiss(animated: true, completion: nil)
        self.uploadImageToServer(imageViewer: imageViewer)
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    func uploadImageToServer(imageViewer: ImageViewer) {
        let imageBase64Str = Utils.convertImageToBase64(image: imageViewer.getImage())
        let imageName = "event_image_" + String(Utils.currentTimeMillis())
        self.showUIActivityIndicator()
        let eventAsyncHttpClient = EventAsyncHttpClient()
        eventAsyncHttpClient.setEventImage(userIdStr: self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!), parentEventIdStr: String(describing: self.mParentEventId!), eventImageName: imageName, base64Str: imageBase64Str, respHandler: { (statusCode, resp) in
            self.stopUIActivityIndicator()
            if let statusCode = statusCode {
                if(statusCode == 200){
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        let lastModifiedTime = json["result"]["lastModifiedTime"].int64Value
                        let mediaUrl = json["result"]["mediaUrl"].stringValue
                        imageViewer.setImageServerUrl(imageServerUrl: mediaUrl);
                        imageViewer.setLastModifiedTime(lastModifiedTime: lastModifiedTime);
                        self.mImageContainer.add(url: imageViewer.getImageServerUrl(), imageViewer: imageViewer)
                        self.mImageContainer.refreshImageViewerList()
                        self.mImageCollectionView.reloadData()
                        self.showAlertMsg("Event picture uploaded successfully")
                    }else {
                        self.showAlertMsg("error getting data from server")
                    }
                }else {
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        self.showAlertMsg(json["error"].stringValue)
                    }else {
                        self.showAlertMsg("error adding image")
                    }
                }
            }else {
                self.showAlertMsg("error connecting to server")
            }
        })

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mImageContainer.getImageViewerList().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewControllerCollectionViewCell", for: indexPath) as! ImageViewControllerCollectionViewCell
        return cell.getCellView(indexPath: indexPath)
    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        self.fetchImagesFromSever(visibleStartIndex: indexPath.row - collectionView.visibleCells.count, visibleEndIndex: indexPath.row - 1)
//    }
    
    func fetchImagesFromSever(visibleStartIndex:Int, visibleEndIndex: Int) {
        
        
        self.showUIActivityIndicator()
        let eventAsyncHttpClient = EventAsyncHttpClient()
        eventAsyncHttpClient.getEventImagesUrls(userIdStr: self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!), parentEventIdStr: String(self.mParentEventId!), offset: visibleStartIndex, limit: visibleEndIndex, respHandler: { (statusCode, resp) in
            self.stopUIActivityIndicator()
            if let statusCode = statusCode {
                if(statusCode == 200){
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        if let jsonImages = json["result"].array {
                            for jsonImage in jsonImages {
                                self.mImageContainer.populateMe(jsonImage)
                                // TODO -> Need to store image locally and check if they exist before getting it from server
                                self.loadAsyncUrl(jsonImage["mediaUrl"].stringValue)
                            }
                        }else {
                            print("error parsing json")
                        }
                    }else {
                        self.showAlertMsg("error getting data from server")
                    }
                }else {
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        self.showAlertMsg(json["error"].stringValue)
                    }else {
                        self.showAlertMsg("error getting images")
                    }
                }
            }else {
                self.showAlertMsg("error connecting to server")
            }
        })
    }
    
    func loadAsyncUrl(_ url: String){
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            let eventAsyncHttpClient: EventAsyncHttpClient = EventAsyncHttpClient()
            eventAsyncHttpClient.getEventImage(userIdStr: self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!), parentEventIdStr: String(self.mParentEventId!), imageUrl: url, respHandler: { (statusCode, resp) in
                if (statusCode == 200) {
                    let json = JSON(resp.value!)
                    let imageUrl = json["result"]["imageUrl"].stringValue
                    let imageViewer = self.mImageContainer.get(url: imageUrl)
                    imageViewer.setImage(image: Utils.convertBase64ToImage(base64String: json["result"]["imageBase64Str"].stringValue))
                    self.mImageContainer.refreshImageViewerList()
                    
                    DispatchQueue.main.async {
                        self.mImageCollectionView.reloadData()
                    }
                }else {
                    print("error loading event photos")
                }
                
            })
            
        })
    }

    
    
}
