//
//  APIManagerErrors.swift
//  SwiftUIDemo
//
//  Created by Mac on 20/09/21.
//

import Foundation

//MARK: API Related Custom Errors
public enum APIManagerErrors: Error {
    
    case FileUploadFailed
    case InvalidResponseFromServer
    case Unauthorized
    case JSONParsingFailure
    case InternetOffline
    
    //MARK: All Custom Error Messages
    public enum ErrorMessages: String {
        case FileUploadFailed = "Their was issue in connecting to server, please try again after some time."
        case InvalidResponseFromServer = "Server response is invalid"
        case Unauthorized = "You do not have permission to use app, please login again."
        case JSONParsingFailure = "Please try again, their was in parsing response. if issue persist contact admin."
        case InternetOffline = "Internet connection appears to be offline."
    }
    
}

//MARK: API Related Custom Error Messages
extension APIManagerErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .FileUploadFailed:
            return NSLocalizedString(ErrorMessages.FileUploadFailed.rawValue, comment: "")
        case .InvalidResponseFromServer:
            return NSLocalizedString(ErrorMessages.InvalidResponseFromServer.rawValue, comment: "")
        case .Unauthorized:
            return NSLocalizedString(ErrorMessages.Unauthorized.rawValue, comment: "")
        case .JSONParsingFailure:
            return NSLocalizedString(ErrorMessages.JSONParsingFailure.rawValue, comment: "")
        case .InternetOffline:
            return NSLocalizedString(ErrorMessages.InternetOffline.rawValue, comment: "")
        }
    }
}


