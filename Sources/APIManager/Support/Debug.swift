//
//  Debug.swift
//  APICallDemo
//
//  Created by Mac on 16/09/21.
//

import Foundation

public struct Debug{
    
    public static func Log(_ msg :String){
        #if DEBUG
        print(msg)
        #endif
    }
    
    public static func DebugPrint(_ error : Any){
        #if DEBUG
        debugPrint(error)
        #endif
    }
}
