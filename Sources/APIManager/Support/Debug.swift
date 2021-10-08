//
//  Debug.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation

public struct Debug{
    ///Writes the textual representations of the given items into the standard output.
    public static func log(_ msg :String){
        print(msg)
    }
    
    ///Writes the textual representations of the given items most suitable for debugging into the standard output.
    public static func debugLog(_ error : Any){
        debugPrint(error)
    }
}
