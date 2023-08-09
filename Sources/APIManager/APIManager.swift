//
//  APIManager.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation
import Alamofire

//MARK: APIManager Class
public class APIManager: NSObject, APIManagerProtocol {
    
    var sslPinningType : SSLPinningType = .disable
    var isDebugOn : Bool!
    
    var manager: APIManagerProtocol!
    
    /// APIManager is simple api wrapper tool that is made for making ios development fast and easy
    /// - Parameters:
    ///   - statusCodeForCallBack: this is api status code which will be used in case you want to break normal flow and get call back.
    ///   - statusMessageKey: using this key, manager will try to get string message from json and pass it to `statusCodeCallBack`.
    ///   - statusCodeCallBack: when manager encounter code mentioned in `statusCodeForCallBack`, manager will trigger this callback to handle specific case instead of normal flow, e.g. we need to handle token expiry condition in our app we will use this call back, normal flow is broken as we do not want to show error message. call back will give message based on key provided in `statusMessageKey` param.
    ///   - sslPinningType: this is ssl pinning type
    ///   - isDebugOn: using this you can toggle debug api request print.
    public init(sslPinningType : SSLPinningType = .disable, encoding : ParameterEncoding = JSONEncoding.default, isDebugOn : Bool = false) {
        self.sslPinningType = sslPinningType
        manager = AFAPIManager(sslPinningType: sslPinningType, isDebugOn: isDebugOn)
    }
    
}

//MARK: request with codable support
extension APIManager {
    
    public func requestData(_ url: String, httpMethod: APIHTTPMethod, header: [String : String]? = nil, param: [String : Any]? = nil, requestTimeout: TimeInterval = 60, completion: @escaping (Int, Result<Data, Error>) -> Void) {
        
        guard Reachability.isConnectedToNetwork() == true else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                completion(APIManagerError.internetOffline.statusCode,.failure(APIManagerError.internetOffline))
            }
            return
        }
        
        manager.requestData(url, httpMethod: httpMethod, header: header, param: param, requestTimeout: requestTimeout, completion: completion)
        
    }
    
    /// This method is used for making request to endpoint with provided configurations.
    /// - Parameters:
    ///   - endpoint: Web Service Name
    ///   - httpMethod: Type of api request
    ///   - header: Header to be sent to api
    ///   - param: Parameters to be sent to api, if no parameter then do not pass this parameter
    ///   - requesttimeout: Request timeout
    ///   - completion: Response of API: containing codable or error
    public func requestDecodable<T:Codable>(_ url : String, decodeWith: T.Type, httpMethod : APIHTTPMethod, header: [String:String]? = nil, param:[String: Any]? = nil, requestTimeout: TimeInterval = 60, completion : @escaping (Int,Result<T, Error>) -> Void) {
        
        guard Reachability.isConnectedToNetwork() == true else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                completion(APIManagerError.internetOffline.statusCode,.failure(APIManagerError.internetOffline))
            }
            return
        }
        
        manager.requestDecodable(url, decodeWith: decodeWith, httpMethod: httpMethod, header: header, param: param, requestTimeout: requestTimeout, completion: completion)
        
    }
    
}

//MARK: upload request
extension APIManager {
    public func upload(_ url: String, httpMethod: APIHTTPMethod = .POST, header: [String : String]?, param: [String : Any]?, files: [APIFileModel], requestTimeout: TimeInterval = 120, uploadProgressQueue: DispatchQueue, uploadProgress: @escaping (Double) -> Void, completion: @escaping (Int, Result<Data, Error>) -> Void) throws {
        
        guard Reachability.isConnectedToNetwork() == true else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                completion(APIManagerError.internetOffline.statusCode,.failure(APIManagerError.internetOffline))
            }
            return
        }
        
        try manager.upload(url, httpMethod: httpMethod, header: header, param: param, files: files, requestTimeout: requestTimeout, uploadProgressQueue: uploadProgressQueue, uploadProgress: uploadProgress, completion: completion)
    }
}


extension APIManager {
    public func cancelAllRequests(){
        manager.cancelAllRequests()
    }
}
