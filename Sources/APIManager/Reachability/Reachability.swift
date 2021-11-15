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
    static var isConnected: Bool = false
    
    static func isConnectedToNetwork() -> Bool {
        
        guard monitor.pathUpdateHandler == nil else { return false}
        let holdOn = DispatchGroup()
        holdOn.enter()
        monitor.pathUpdateHandler = { update in
            isConnected = update.status == .satisfied ? true : false
            holdOn.leave()
        }
        monitor.start(queue: DispatchQueue(label: "InternetMonitor"))
        holdOn.wait()
        return isConnected
        
        
    }
    
}
