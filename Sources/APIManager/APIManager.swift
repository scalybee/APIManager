//
//  APIManager.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//


import Foundation

//MARK: APIManager Class
public class APIManager: NSObject {
    
    var sslPinningType : SSLPinningType = .disable
    var isDebugOn : Bool!
    
    var manager: APIManagerProtocol!
    
    public init(sslPinningType : SSLPinningType = .disable, isDebugOn : Bool = false) {
        self.sslPinningType = sslPinningType
        Reachability.start()
        manager = AFAPIManager(sslPinningType: sslPinningType, isDebugOn: isDebugOn)
    }
    
    /// This method is used for making request to endpoint with provided configurations.
    /// - Parameters:
    ///   - endpoint: Web Service Name
    ///   - httpMethod: Type of api request
    ///   - header: Header to be sent to api
    ///   - param: Parameters to be sent to api, if no parameter then do not pass this parameter
    ///   - requesttimeout: Request timeout
    ///   - completion: Response of API: containing codable or error
    public func request<T:Codable>(_ endpoint : String, httpMethod : APIHTTPMethod, header: [String:String]?, param:[String: Any]? = nil, requestTimeout: TimeInterval = 90, completion : @escaping (Int,Result<T, Error>) -> Void){
        
        guard Reachability.isConnectedToNetwork == true else {
            completion(APIManagerErrors.internetOffline.statusCode,.failure(APIManagerErrors.internetOffline))
            return
        }
        
        manager.request(url: endpoint, httpMethod: httpMethod, header: header, requestTimeout: requestTimeout, param: param) { statuscode,result in
            switch result{
                
            case .success(let jsondata):
                if let users = try? JSONDecoder().decode(T.self, from: jsondata) {
                    completion(statuscode, .success(users))
                }
                else {
                    completion(APIManagerErrors.jsonParsingFailure.statusCode, .failure(APIManagerErrors.jsonParsingFailure))
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
