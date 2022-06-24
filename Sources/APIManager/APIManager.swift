//
//  APIManager.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

/**
 * APIManager Init
 * - Parameters:
 *  - statusCodeForCallBack: this is api status code which will be used in case you want to break normal flow and get call back.
 *  - statusMessageKey: using this key, manager will try to get string message from json and pass it to statusCodeCallBack.
 *  - statusCodeCallBack: when manager encounter code mentioned in statusCodeForCallBack, manager will trigger this callback to handle specific case instead of normal flow, e.g. we need to handle token expiry condition in our app we will use this call back, normal flow is broken as we do not want to show error message. call back will give message based on key provided in statusMessageKey param.
 *  - sslPinningType: this is ssl pinning type
 *  - isDebugOn: using this you can toggle debug api request print.
 */

import Foundation

//MARK: APIManager Class
public class APIManager: NSObject {
    
    let statusCodeForCallBack: Int?
    let statusMessageKey: String?
    let statusCodeCallBack : ((String?)->Void)?
    
    var sslPinningType : SSLPinningType = .disable
    var isDebugOn : Bool!
    
    var manager: APIManagerProtocol!
   
    /// - Parameters:
    ///   - statusCodeForCallBack: this is api status code which will be used in case you want to break normal flow and get call back.
    ///   - statusMessageKey: using this key, manager will try to get string message from json and pass it to `statusCodeCallBack`.
    ///   - statusCodeCallBack: when manager encounter code mentioned in `statusCodeForCallBack`, manager will trigger this callback to handle specific case instead of normal flow, e.g. we need to handle token expiry condition in our app we will use this call back, normal flow is broken as we do not want to show error message. call back will give message based on key provided in `statusMessageKey` param.
    ///   - sslPinningType: this is ssl pinning type
    ///   - isDebugOn: using this you can toggle debug api request print.
    public init(statusCodeForCallBack: Int? = nil, statusMessageKey: String? = nil, statusCodeCallBack : ((String?)->Void)? = nil, sslPinningType : SSLPinningType = .disable, isDebugOn : Bool = false) {
        self.statusCodeForCallBack = statusCodeForCallBack
        self.statusMessageKey = statusMessageKey
        self.statusCodeCallBack = statusCodeCallBack
        self.sslPinningType = sslPinningType
        manager = AFAPIManager(statusCodeForCallBack: statusCodeForCallBack, sslPinningType: sslPinningType, isDebugOn: isDebugOn)
    }
    
    /// This method is used for making request to endpoint with provided configurations.
    /// - Parameters:
    ///   - endpoint: Web Service Name
    ///   - httpMethod: Type of api request
    ///   - header: Header to be sent to api
    ///   - param: Parameters to be sent to api, if no parameter then do not pass this parameter
    ///   - requesttimeout: Request timeout
    ///   - completion: Response of API: containing codable or error
    public func request<T:Codable>(_ endpoint : String, httpMethod : APIHTTPMethod, header: [String:String]?, param:[String: Any]? = nil, requestTimeout: TimeInterval = 60, completion : @escaping (Int,Result<T, Error>) -> Void){
        
        guard Reachability.isConnectedToNetwork() == true else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                completion(APIManagerErrors.internetOffline.statusCode,.failure(APIManagerErrors.internetOffline))
            }
            return
        }
        
        manager.request(url: endpoint, httpMethod: httpMethod, header: header, requestTimeout: requestTimeout, param: param) { [weak self] statuscode,result in
            switch result{
                
            case .success(let jsondata):
                if let statusCodeForCallBack = self?.statusCodeForCallBack,  statuscode == statusCodeForCallBack, let statusMessageKey = self?.statusMessageKey, self?.statusCodeCallBack != nil {
                    let statusMessage = try? (JSONSerialization.jsonObject(with: jsondata, options: .mutableContainers) as? [String:Any])?[statusMessageKey] as? String
                    self?.statusCodeCallBack?(statusMessage)
                }
                else{
                    do {
                        let users = try JSONDecoder().decode(T.self, from: jsondata)
                        completion(statuscode, .success(users))
                    }
                    catch {
                        completion(APIManagerErrors.jsonParsingFailure.statusCode, .failure(error))
                    }
                }
                
            case .failure(let error):
                if (error as NSError).code == APIManagerErrors.internetOffline.statusCode {
                    completion(APIManagerErrors.internetOffline.statusCode,.failure(APIManagerErrors.internetOffline))
                }
                else{
                    completion(statuscode,.failure(error))
                }
                
            }
            
        }
        
    }
    
    public func cancelAllRequests(){
        manager.cancelAllRequests()
    }
    
}
