//
//  Reachability.swift
//  APICallDemo
//
//  Created by Mac on 17/09/21.
//

import Foundation
import SystemConfiguration
import Network

struct Reachability {
    
    private static let monitor = NWPathMonitor()
    
    static func isConnectedToNetwork(completion:@escaping(Bool)->Void) {
        
        guard monitor.pathUpdateHandler == nil else {
            completion(false)
            return
        }

        monitor.pathUpdateHandler = { update in
            let isConnected = update.status == .satisfied ? true : false
            completion(isConnected)
        }
        
        monitor.start(queue: DispatchQueue(label: "InternetMonitor"))
        
    }
    
}
