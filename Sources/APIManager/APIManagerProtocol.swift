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
    func request(url: String, httpMethod: APIHTTPMethod ,header: [String:String]?, requestTimeout : TimeInterval, param: [String:Any]?, completion: @escaping (Result<Data,Error>)-> Void)
}
