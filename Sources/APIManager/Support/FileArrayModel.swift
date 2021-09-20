//
//  FileArrayModel.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation

//MARK: Struct for Uploading Files
public struct FileArrayModel {
    var fileURL : URL? = nil
    var withName : String? = nil
    var fileName : String? = nil
    var mimeType : String? = nil
    var data : Data? = nil
}
