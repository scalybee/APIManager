//
//  APIFileModel.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation

//MARK: Struct for Uploading Files
public struct APIFileModel {
    let fileURL : URL
    let withName : String
    let fileName : String
    let mimeType : String
}
