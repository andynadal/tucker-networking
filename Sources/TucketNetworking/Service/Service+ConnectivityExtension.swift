//
//  Service+ConnectivityExtension.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 11/23/25.
//

import Foundation

public extension Service {
    func doesNotCheckConnectivity() -> Self {
        checkConnectivity = false
        return self
    }
}
