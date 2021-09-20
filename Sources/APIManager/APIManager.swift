//
//  APIManager.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//


import Foundation

//MARK: APIManager Class
public class APIManager: NSObject {
    
    private var manager: APIManagerProtocol!
    
    public override init() {
        super.init()
        manager = AFAPIManager()
    }
    
    init(domains : [String]) {
        manager = AFAPIManager(SSLPinningDomains: domains)
    }
    
    /// This method is used for making request to endpoint with provided configurations.
    /// - Parameters:
    ///   - endpoint: Web Service Name
    ///   - httpMethod: Type of api request
    ///   - header: Header to be sent to api
    ///   - param: Parameters to be sent to api, if no parameter then do not pass this parameter
    ///   - requesttimeout: Request timeout
    ///   - completion: Response of API: containing codable or error
    public func APIRequest<T:Codable>(_ endpoint : String, httpMethod : APIHTTPMethod, header: [String:String]?, param:[String: Any]? = nil, requesttimeout: TimeInterval = 90, completion : @escaping (Result<T, Error>) -> Void){
        
        guard Reachability.isConnectedToNetwork() == true else {
            completion(.failure(APIManagerErrors.InternetOffline))
            return
        }
        
        manager.request(url: endpoint, httpMethod: httpMethod, header: header, requesttimeout: requesttimeout, param: param) { result in
            switch result{
            case .success(let jsondata):
                if let users = try? JSONDecoder().decode(T.self, from: jsondata){
                    completion(.success(users))
                }
                else{
                    completion(.failure(APIManagerErrors.JSONParsingFailure))
                }
                break
            case .failure(let error):
                if (error as NSError).code == URLError.Code.notConnectedToInternet.rawValue{
                    completion(.failure(APIManagerErrors.InternetOffline))
                }
                else{
                    completion(.failure(error))
                }
                break
            }
        }
        
    }
    
}
