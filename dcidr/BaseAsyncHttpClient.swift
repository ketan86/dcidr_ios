//
//  BaseHttpClient.swift
//  dcidr
//
//  Created by John Smith on 12/27/16.
//  Copyright © 2016 dcidr. All rights reserved.
//
import Alamofire
import SwiftyJSON


//var Manager : Alamofire.Manager = {
//    // Create the server trust policies
//    let serverTrustPolicies: [String: ServerTrustPolicy] = [
//        "maskeddomain.com": .DisableEvaluation
//    ]
//    // Create custom manager
//    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//    configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
//    let man = Alamofire.Manager(
//        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
//        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
//    )
//    return man
//    }()

class BaseAsyncHttpClient {
    
    var userCache: UserCache!
    init() {
        self.userCache = DcidrApplication.getInstance().getUserCache()
    }
    
    func get(_ url: URLConvertible, respCb: @escaping (_ statusCode: Int?, _ respCb: Result<Any>)->()){
        var url = url
        let headers = self.getHeaders()
        url = getAbsoluteUrl(url)
        Alamofire.request(url, method:HTTPMethod.get ,encoding: URLEncoding.default, headers: headers).responseJSON {
            resp in
            //print(response.0)  // original URL request
            //print(response.1?.statusCode) // HTTP URL response
            //print(response.2.value)   // result of response serialization
            respCb(resp.response?.statusCode, resp.result)
        }
    }
    
    func post(_ url: URLConvertible, params: [String:Any], respCb: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()){
        var url = url
        let headers = self.getHeaders() 
        url = getAbsoluteUrl(url)
        //print(params)
        Alamofire.request(url, method: HTTPMethod.post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { resp in
            //print(response.0)  // original URL request
            //print(response.1?.statusCode) // HTTP URL response
            //print(response.2.value)   // result of response serialization
            respCb(resp.response?.statusCode, resp.result)
        }
    }
    
    func put(_ url: URLConvertible, params: [String:Any], respCb: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()){
        var url = url
        let headers = self.getHeaders()
        url = getAbsoluteUrl(url)
        Alamofire.request(url, method: HTTPMethod.put, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { resp in
            //print(response.0)  // original URL request
            //print(response.1?.statusCode) // HTTP URL response
            //print(response.2.value)   // result of response serialization
            respCb(resp.response?.statusCode, resp.result)
        }
    }
    
    func getAbsoluteUrl(_ relativeUrl: URLConvertible) -> URLConvertible {
        return DcidrConstant.DCIDR_SERVER_URL + DcidrConstant.BASE_URL + String(describing: relativeUrl)
    }
    
    func getHeaders() -> [String:String]{
        var headers:[String:String] = [String:String]()
        var authToken : String = ""
        var deviceId : String = ""
        if let unwrapped = self.userCache.getPref("authToken") {
            authToken = unwrapped
        }
        if let unwrapped = self.userCache.getPref("deviceId") {
            deviceId = unwrapped
        }
        headers = [
            "deviceId": deviceId,
            "authToken": authToken
        ]
        return headers
    }
}
