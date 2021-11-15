//
//  Reachability.swift
//  APICallDemo
//
//  Created by Mac on 17/09/21.
//

import Foundation
import Network

struct Reachability {
    
    private static let monitor = NWPathMonitor()
    
    static var isConnectedToNetwork = false
    
    /// Monitors internet connectivity changes. Updates with every change in connectivity.
    /// Updates variables for availability and if it's expensive (cellular).
    static func startMonitoring() {
        guard monitor.pathUpdateHandler == nil else { return }
        
        monitor.pathUpdateHandler = { update in
            Reachability.isConnectedToNetwork = update.status == .satisfied ? true : false
        }
        
        monitor.start(queue: DispatchQueue(label: "InternetMonitor"))
    }
    
    static func stopMonitoring() {
        monitor.cancel()
    }
    
}
