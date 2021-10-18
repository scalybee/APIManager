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
    var sslPinningType : SSLPinningType = .disable
    var isDebugOn: Bool!
    
    let rootURL = Bundle.main.infoDictionary?["ROOT_URL"] as? String
    
    fileprivate var sessionManager : Session!// AF.session
    
    init(encoding : ParameterEncoding = JSONEncoding.default, sslPinningType : SSLPinningType = .disable, isDebugOn : Bool = false) {
        self.encoding = encoding
        self.sslPinningType = sslPinningType
        self.isDebugOn = isDebugOn
        checkAndCreateSessionWithSSLPinning()
    }
    
}

//MARK: SSL Pinning
extension AFAPIManager {
    
    fileprivate func getDomainFrom(_ url: String) -> String?{
        let baseurl = url.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
        let cmp = baseurl.components(separatedBy: "/")
        return cmp.first
    }
    
    /// Get SSL Pinning Type according to provided type selection
    fileprivate func getTrustEvaluator(domain : String) -> [String: ServerTrustEvaluating]{
        switch sslPinningType {
        case .certificate:
            return [domain: PinnedCertificatesTrustEvaluator()]
        case .publicKey:
            return [domain: PublicKeysTrustEvaluator()]
        case .disable:
            return [domain: DisabledTrustEvaluator()]
        }
    }
    
    /// Create AF Session according to selected configurations
    fileprivate func checkAndCreateSessionWithSSLPinning(){
        
        guard let rooturl = rootURL, sslPinningType != .disable, let domain = getDomainFrom(rooturl) else {
            sessionManager = Alamofire.Session()
            return
        }
       
        let evaluators : [String: ServerTrustEvaluating] = getTrustEvaluator(domain: domain)
        
        let serverTrustManager = ServerTrustManager(evaluators: evaluators)
        
        sessionManager = Session(serverTrustManager: serverTrustManager)
        
    }
}


//MARK: API Request and Response Parsing
extension AFAPIManager{
    
    func request(url: String, httpMethod: APIHTTPMethod, header: [String : String]?, requestTimeout: TimeInterval = 90, param: [String : Any]?, completion: @escaping (Int,Result<Data, Error>) -> Void) {
        
        var headers = HTTPHeaders()
        
        header?.forEach({ headerValue in
            headers.add(HTTPHeader(name: headerValue.key, value: headerValue.value))
        })
        
        sessionManager.session.configuration.timeoutIntervalForRequest = requestTimeout
        
        if isDebugOn {
            Debug.log("\n\n===========Request===========")
            Debug.log("Url: " + url)
            Debug.log("Method: " + httpMethod.rawValue)
            Debug.log("Header: \(header ?? [:])")
            Debug.log("Parameter: \(param ?? [:])")
            Debug.log("=============================\n")
        }
        
        sessionManager.request(url, method: HTTPMethod(rawValue: httpMethod.rawValue), parameters: param, encoding: encoding, headers: headers).validate(statusCode: 200..<300).responseJSON { res in
            
            let statuscode = res.response?.statusCode ?? APIManagerErrors.unauthorized.statusCode
            if self.isDebugOn == true{
                Debug.log("\n\n===========Response===========")
                Debug.log("Url: " + url)
                Debug.log("Method: " + httpMethod.rawValue)
                Debug.log("Header: \(header ?? [:])")
                Debug.log("Parameter: \(param ?? [:])")
                Debug.log("Response: " + (res.data != nil ? String.init(data: res.data!, encoding: .utf8) ?? "NO DATA" : "NO DATA"))
                Debug.log("=============================\n")
            }
            
            if let error = res.error {
                completion(statuscode, .failure(error))
            }
            else if (200..<300) ~= ((res.response?.statusCode) ?? 0) {
                self.parseResponse(res, completion: completion)
            } else if res.response?.statusCode == APIManagerErrors.unauthorized.statusCode {
                completion(APIManagerErrors.unauthorized.statusCode, .failure(APIManagerErrors.unauthorized))
            } else {
                completion(APIManagerErrors.invalidResponseFromServer.statusCode, .failure(APIManagerErrors.invalidResponseFromServer))
            }
            
        }
        
    }
    
    func parseResponse(_ response : AFDataResponse<Any>, completion: @escaping (Int,Result<Data, Error>) -> Void) {
        let statuscode = response.response?.statusCode ?? APIManagerErrors.unauthorized.statusCode
        switch response.result{
        case .success(let value):
            if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) {
                completion(response.response?.statusCode ?? 200,.success(jsonData))
            }
            else {
                completion(APIManagerErrors.invalidResponseFromServer.statusCode, .failure(APIManagerErrors.invalidResponseFromServer))
            }
            break
        case .failure(let error):
            completion(statuscode, .failure(error))
        }
    }
}
