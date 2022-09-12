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
    
    var sessionManager : Session!// AF.session
    
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
    
    func requestDecodable<T>(_ url: String, decodeWith: T.Type, httpMethod: APIHTTPMethod, header: [String : String]?, param: [String : Any]?, requestTimeout: TimeInterval, completion: @escaping (Int, Result<T, Error>) -> Void) where T : Decodable, T : Encodable {
        
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
        
        sessionManager.request(url, method: HTTPMethod(rawValue: httpMethod.rawValue), parameters: param, encoding: encoding, headers: headers)
            .responseDecodable(of: decodeWith) { res in
                
                let statuscode = res.response?.statusCode ?? APIManagerError.sessionExpired.statusCode
                
                if self.isDebugOn == true{
                    Debug.log("\n\n===========Response===========")
                    Debug.log("Url: " + url)
                    Debug.log("StatusCode: \(res.response?.statusCode ?? 0)")
                    Debug.log("Method: " + httpMethod.rawValue)
                    Debug.log("Header: \(header ?? [:])")
                    Debug.log("Parameter: \(param ?? [:])")
                    Debug.log("Response: " + (res.data != nil ? String.init(data: res.data!, encoding: .utf8) ?? "NO DATA" : "NO DATA"))
                    Debug.log("=============================\n")
                }
                
                switch res.result {
                    
                case .success(let decoded):
                    completion(statuscode, .success(decoded))
                    
                case .failure(let error):
                    if (error as NSError).code == APIManagerError.internetOffline.statusCode {
                        completion(APIManagerError.internetOffline.statusCode,.failure(APIManagerError.internetOffline))
                    }
                    else {
                        completion(statuscode,.failure(error))
                    }
                    
                }
                
            }
        
    }
    
    func requestData(_ url: String, httpMethod: APIHTTPMethod, header: [String : String]?, param: [String : Any]?, requestTimeout: TimeInterval, completion: @escaping (Int,Result<Data, Error>) -> Void) {
        
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
        
        sessionManager.request(url, method: HTTPMethod(rawValue: httpMethod.rawValue), parameters: param, encoding: encoding, headers: headers)
            .responseData { res in
                
                let statuscode = res.response?.statusCode ?? APIManagerError.sessionExpired.statusCode
                
                if self.isDebugOn == true{
                    Debug.log("\n\n===========Response===========")
                    Debug.log("Url: " + url)
                    Debug.log("API status code: \(res.response?.statusCode ?? 0)")
                    Debug.log("Method: " + httpMethod.rawValue)
                    Debug.log("Header: \(header ?? [:])")
                    Debug.log("Parameter: \(param ?? [:])")
                    Debug.log("Response: " + (res.data != nil ? String.init(data: res.data!, encoding: .utf8) ?? "NO DATA" : "NO DATA"))
                    Debug.log("=============================\n")
                }
                
                switch res.result {
                    
                case .success(let value):
                    completion(res.response?.statusCode ?? 200,.success(value))
                    
                case .failure(let error):
                    if (error as NSError).code == APIManagerError.internetOffline.statusCode {
                        completion(APIManagerError.internetOffline.statusCode,.failure(APIManagerError.internetOffline))
                    }
                    else {
                        completion(statuscode,.failure(error))
                    }
                    
                }
                
            }
        
    }
    
    func upload(_ url: String, httpMethod: APIHTTPMethod = .POST, header: [String : String]?, param: [String : Any]?, files: [APIFileModel], requestTimeout: TimeInterval, uploadProgressQueue: DispatchQueue, uploadProgress: @escaping(Double)->Void , completion: @escaping (Int,Result<Data, Error>) -> Void) throws {
        
        var hTTPHeaders = HTTPHeaders()
        
        header?.forEach({ headerValue in
            hTTPHeaders.add(HTTPHeader(name: headerValue.key, value: headerValue.value))
        })
        
        hTTPHeaders.add(HTTPHeader(name: "Content-type", value: "multipart/form-data"))
        
        let urlRequest = try URLRequest(url: url, method: HTTPMethod(rawValue: httpMethod.rawValue), headers: hTTPHeaders)
        
        sessionManager.session.configuration.timeoutIntervalForRequest = requestTimeout
        
        if isDebugOn {
            Debug.log("\n\n===========Request===========")
            Debug.log("Url: " + url)
            Debug.log("Method: " + httpMethod.rawValue)
            Debug.log("Header: \(header ?? [:])")
            Debug.log("Parameter: \(param ?? [:])")
            Debug.log("Files:")
            print(files)
            Debug.log("=============================\n")
        }
        
        sessionManager.upload(multipartFormData: { multiPart in
            param?.forEach({ (paramKey, paramValue) in
                if let arrayList = paramValue as? [[String: Any]] {
                    arrayList.enumerated().forEach { arrayIndex, arrayValue in
                        arrayValue.forEach { dictKey, dictValue in
                            if let temp = dictValue as? Bool, let tempData = "\(temp ? 1 : 0)".data(using: .utf8) {
                                multiPart.append(tempData, withName: "\(paramKey)[\(arrayIndex)][\(dictKey)]" as String)
                                print("\(paramKey)[\(arrayIndex)][\(dictKey)] : \(temp)")
                            }
                            else if let tempData = "\(dictValue)".data(using: .utf8) {
                                multiPart.append(tempData, withName: "\(paramKey)[\(arrayIndex)][\(dictKey)]" as String)
                                print("\(paramKey)[\(arrayIndex)][\(dictKey)] : \(dictValue)")
                            }
                        }
                    }
                }
                else if let dataArrayList = paramValue as? [Any] {
                    dataArrayList.enumerated().forEach { index, value in
                        if let temp = value as? Bool, let tempData = "\(temp ? 1 : 0)".data(using: .utf8) {
                            multiPart.append(tempData, withName: "\(paramKey)[\(index)]" as String)
                            print("\(paramKey)[\(index)] : \(value)")
                        }
                        else if let dataValue = "\(value)".data(using: .utf8) {
                            multiPart.append(dataValue, withName: "\(paramKey)[\(index)]" as String)
                            print("\(paramKey)[\(index)] : \(value)")
                        }
                    }
                }
                else if let temp = paramValue as? Bool, let tempData = "\(temp ? 1 : 0)".data(using: .utf8) {
                    multiPart.append(tempData, withName: paramKey)
                    print("\(paramKey) : \(paramValue)")
                }
                else if let tempData = "\(paramValue)".data(using: .utf8) {
                    multiPart.append(tempData, withName: paramKey)
                    print("\(paramKey) : \(paramValue)")
                }
            })
            
//                if let temp = value as? NSArray {
//                    if let jsonData = try? JSONSerialization.data(withJSONObject: temp, options:[]) {
//                        multiPart.append(jsonData, withName: key)
//                    }
//                }
//                else if let temp = value as? Bool {
//                    multiPart.append("\(temp ? 1 : 0)".data(using: .utf8)!, withName: key)
//                }
//                else {
//                    multiPart.append("\(value)".data(using: .utf8)!, withName: key)
//                }
//            })
            
            files.forEach { file in
                multiPart.append(file.fileURL, withName: file.withName, fileName: file.fileName, mimeType: file.mimeType)
            }
            
            
        }, with: urlRequest)
            .uploadProgress(queue: uploadProgressQueue) { progress in
                uploadProgress(progress.fractionCompleted)
            }
            .responseData { res in
                
                let statuscode = res.response?.statusCode ?? APIManagerError.sessionExpired.statusCode
                
                if self.isDebugOn == true{
                    Debug.log("\n\n===========Response===========")
                    Debug.log("Url: " + url)
                    Debug.log("API status code: \(res.response?.statusCode ?? 0)")
                    Debug.log("Method: " + httpMethod.rawValue)
                    Debug.log("Header: \(header ?? [:])")
                    Debug.log("Parameter: \(param ?? [:])")
                    Debug.log("Files: ")
                    print(files)
                    Debug.log("Response: " + (res.data != nil ? String.init(data: res.data!, encoding: .utf8) ?? "NO DATA" : "NO DATA"))
                    Debug.log("=============================\n")
                }
                
                switch res.result {
                    
                case .success(let value):
                    completion(res.response?.statusCode ?? 200,.success(value))
                    
                case .failure(let error):
                    if (error as NSError).code == APIManagerError.internetOffline.statusCode {
                        completion(APIManagerError.internetOffline.statusCode,.failure(APIManagerError.internetOffline))
                    }
                    else {
                        completion(statuscode,.failure(error))
                    }
                    
                }
                
            }
    }
    
}

//MARK: Cancel All Request
extension AFAPIManager {
    public func cancelAllRequests(){
        sessionManager.cancelAllRequests()
    }
}
