//
//  APIManagerError.swift
//  SwiftUIDemo
//
//  Created by Mac on 20/09/21.
//

import Foundation

//MARK: API Related Custom Errors
public enum APIManagerError: Error {
    
    case fileUploadFailed
    case invalidResponseFromServer
    case sessionExpired
    case jsonParsingFailure
    case internetOffline
    case apiError(message: String, code: Int)
    
    public var statusCode: Int{
        switch self{
        case .fileUploadFailed:
            return 409
            
        case .invalidResponseFromServer:
            return 500
            
        case .sessionExpired:
            return 419
            
        case .jsonParsingFailure:
            return 422
            
        case .internetOffline:
            return URLError.notConnectedToInternet.rawValue
            
        case .apiError(_, let code):
            return code
            
        }
    }
    
}

//MARK: API Related Custom Error Messages
extension APIManagerError: LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
            
        case .fileUploadFailed:
            return NSLocalizedString("Their was issue in connecting to server, please try again after some time.", comment: "")
            
        case .invalidResponseFromServer:
            return NSLocalizedString("Something went wrong, please try again after some time.", comment: "")
            
        case .sessionExpired:
            return NSLocalizedString("Session has expired, please login again.", comment: "")
            
        case .jsonParsingFailure:
            return NSLocalizedString("Please try again, their was in parsing response. if issue persist contact admin.", comment: "")
            
        case .internetOffline:
            return NSLocalizedString("There is no internet connection in your phone.Please turn on your Wifi/Mobile data!", comment: "")
            
        case .apiError(let message, _):
            return NSLocalizedString(message, comment: "")
            
            
        }
        
    }
    
}


