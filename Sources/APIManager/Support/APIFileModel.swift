//
//  APIFileModel.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation

//MARK: Struct for Uploading Files
public struct APIFileModel {
    public let fileURL : URL
    public let withName : String
    public let fileName : String
    public let mimeType : String
}
