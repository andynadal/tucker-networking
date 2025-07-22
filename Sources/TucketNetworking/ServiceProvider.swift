//
//  ServiceProvider.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

import Foundation

/// Reusable set of configurations to use project-wide
///
/// Here is where Auth can be shared
public protocol ServiceProvider: Sendable {
    static func useHeaders() async throws(NetworkingError) -> [Header]
    static func decoder() -> JSONDecoder
    static func encoder() -> JSONEncoder
    static func route(_ string: String) throws(NetworkingError) -> Service<Self>
    static func session() -> URLSession
    
    associatedtype ErrorBodyType: Decodable & Sendable
}

public extension ServiceProvider {
    static func useHeaders() async throws(NetworkingError) -> [Header] {
        []
    }
    
    static func decoder() -> JSONDecoder {
        JSONDecoder()
    }
    
    static func encoder() -> JSONEncoder {
        JSONEncoder()
    }
    
    static func session() -> URLSession {
        .shared
    }
}
