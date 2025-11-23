//
//  Connection.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 11/23/25.
//

import Hyperconnectivity

public enum Connection: String, Hashable, CaseIterable, Sendable, Identifiable {
    case loading
    case connected
    case notReachable
    case disconnected
    
    init(state: Hyperconnectivity.State) {
        switch state {
        case .cellularWithoutInternet, .ethernetWithoutInternet, .otherWithoutInternet, .wifiWithoutInternet:
            self = .notReachable
        case .disconnected:
            self = .disconnected
        default:
            self = .connected
        }
    }
    
    public var id: String { rawValue }
}
