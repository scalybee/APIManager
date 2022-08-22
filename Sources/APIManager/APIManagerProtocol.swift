//
//  APIManagerProtocol.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation

public enum APIHTTPMethod: String
{
    case POST   = "POST"
    case GET    = "GET"
    case DELETE = "DELETE"
    case PUT    = "PUT"
}

internal protocol APIManagerProtocol {
    /// This func it used for making api request to server.
    /// - Parameters:
    ///   - url: API URL to which request is being made.
    ///   - httpMethod: type of request e.g. get, post etc.
    ///   - header: Headers
    ///   - requestTimeout: Request timeout
    ///   - param: parameters to be sent to server
    ///   - completion: Response of server in either JSON data or error format
    func requestData(_ url: String, httpMethod: APIHTTPMethod ,header: [String:String]?, param: [String:Any]?, requestTimeout : TimeInterval, completion: @escaping (Int,Result<Data,Error>)-> Void)
    func requestDecodable<T:Codable>(_ url : String, decodeWith: T.Type, httpMethod : APIHTTPMethod, header: [String:String]?, param:[String: Any]?, requestTimeout: TimeInterval, completion : @escaping (Int,Result<T, Error>) -> Void)
    func upload(_ url: String, httpMethod: APIHTTPMethod, header: [String : String]?, param: [String : Any]?, files: [APIFileModel], requestTimeout: TimeInterval, uploadProgressQueue: DispatchQueue, uploadProgress: @escaping(Double)->Void , completion: @escaping (Int,Result<Data, Error>) -> Void) throws
    func cancelAllRequests()
}
