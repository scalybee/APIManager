//
//  AFAPIManager.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation
import Alamofire

//MARK: AFAPIManager Class
class AFAPIManager: APIManagerProtocol {
    
    var encoding : ParameterEncoding = JSONEncoding.default
    var sslPinningType : SSLPinningType = .Disable
    
    let rootURL = Bundle.main.infoDictionary?["ROOT_URL"] as? String
    
    fileprivate var sessionManager : Session!// AF.session
    
    init(encoding : ParameterEncoding = JSONEncoding.default, sslPinningType : SSLPinningType = .Disable) {
        self.encoding = encoding
        self.sslPinningType = sslPinningType
        checkAndCreateSessionWithSSLPinning()
    }
    
}

//MARK: SSL Pinning
extension AFAPIManager {
    
    /// Get SSL Pinning Type according to provided type selection
    fileprivate func GetTrustEvaluator(domain : String) -> [String: ServerTrustEvaluating]{
        switch sslPinningType {
        case .Certificate:
            return [domain: PinnedCertificatesTrustEvaluator()]
        case .PublicKey:
            return [domain: PublicKeysTrustEvaluator()]
        case .Disable:
            return [domain: DisabledTrustEvaluator()]
        }
    }
    
    /// Create AF Session according to selected configurations
    fileprivate func checkAndCreateSessionWithSSLPinning(){
        
        guard let rooturl = rootURL, sslPinningType != .Disable else {
            sessionManager = Alamofire.Session()
            return
        }
        
        let evaluators : [String: ServerTrustEvaluating] = GetTrustEvaluator(domain: rooturl)
        
        let serverTrustManager = ServerTrustManager(evaluators: evaluators)
        
        sessionManager = Session(serverTrustManager: serverTrustManager)
        
    }
}


//MARK: API Request and Response Parsing
extension AFAPIManager{
    
    func request(url: String, httpMethod: APIHTTPMethod, header: [String : String]?, requesttimeout: TimeInterval = 90, param: [String : Any]?, completion: @escaping (Result<Data, Error>) -> Void) {
        
        var headers = HTTPHeaders()
        
        header?.forEach({ headerValue in
            headers.add(HTTPHeader(name: headerValue.key, value: headerValue.value))
        })
        
        sessionManager.session.configuration.timeoutIntervalForRequest = requesttimeout
        
        Debug.Log("\n\n===========Request===========")
        Debug.Log("Url: " + url)
        Debug.Log("Method: " + httpMethod.rawValue)
        Debug.Log("Header: \(header ?? [:])")
        Debug.Log("Parameter: \(param ?? [:])")
        Debug.Log("=============================\n")
        
        sessionManager.request(url, method: HTTPMethod(rawValue: httpMethod.rawValue), parameters: param, encoding: encoding, headers: headers).validate(statusCode: 200..<300).responseJSON { res in
            
            Debug.Log("\n\n===========Response===========")
            Debug.Log("Url: " + url)
            Debug.Log("Method: " + httpMethod.rawValue)
            Debug.Log("Header: \(header ?? [:])")
            Debug.Log("Parameter: \(param ?? [:])")
            Debug.Log("Response: " + (res.data != nil ? String.init(data: res.data!, encoding: .utf8) ?? "NO DATA" : "NO DATA"))
            Debug.Log("=============================\n")
            if let error = res.error {
                completion(.failure(error))
            }
            else if (200..<300) ~= ((res.response?.statusCode) ?? 0) {
                self.ParseResponse(res, completion: completion)
            } else if res.response?.statusCode == 401 {
                completion(.failure(APIManagerErrors.Unauthorized))
            } else {
                completion(.failure(APIManagerErrors.InvalidResponseFromServer))
            }
            
        }
        
    }
    
    func ParseResponse(_ response : AFDataResponse<Any>, completion: @escaping (Result<Data, Error>) -> Void) {
        switch response.result{
        case .success(let value):
            if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []){
                completion(.success(jsonData))
            }
            else{
                completion(.failure(APIManagerErrors.InvalidResponseFromServer))
            }
            break
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
