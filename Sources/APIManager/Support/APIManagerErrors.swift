//
//  APIManagerErrors.swift
//  SwiftUIDemo
//
//  Created by Mac on 20/09/21.
//

import Foundation

//MARK: API Related Custom Errors
public enum APIManagerErrors: Error {
    
    case fileUploadFailed
    case invalidResponseFromServer
    case sessionExpired
    case jsonParsingFailure
    case internetOffline
    case apiError(message: String, code: Int)
    
    //MARK: All Custom Error Messages
    private enum ErrorMessages: String {
        case fileUploadFailed = "Their was issue in connecting to server, please try again after some time."
        case invalidResponseFromServer = "Something went wrong, please try again after some time."
        case sessionExpired = "Token has expired."
        case jsonParsingFailure = "Please try again, their was in parsing response. if issue persist contact admin."
        case internetOffline = "There is no internet connection in your phone.Please turn on your Wifi/Mobile data!"
    }
    
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
extension APIManagerErrors: LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
            
        case .fileUploadFailed:
            return NSLocalizedString(ErrorMessages.fileUploadFailed.rawValue, comment: "")
            
        case .invalidResponseFromServer:
            return NSLocalizedString(ErrorMessages.invalidResponseFromServer.rawValue, comment: "")
            
        case .sessionExpired:
            return NSLocalizedString(ErrorMessages.sessionExpired.rawValue, comment: "")
            
        case .jsonParsingFailure:
            return NSLocalizedString(ErrorMessages.jsonParsingFailure.rawValue, comment: "")
            
        case .internetOffline:
            return NSLocalizedString(ErrorMessages.internetOffline.rawValue, comment: "")
            
        case .apiError(let message, _):
            return NSLocalizedString(message, comment: "")
            
            
        }
        
    }
    
}


