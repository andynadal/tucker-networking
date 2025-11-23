//
//  File.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 11/23/25.
//

import Testing
import Foundation
@testable import TuckerNetworking

// Empty Provider for testing query functionality without making actual API calls
enum ConnectivityProvider {
    enum Connected: ServiceProvider {
        typealias ErrorBodyType = ErrorBody
        
        static func route(_ string: String) throws(NetworkingError) -> Service<Self> {
            do {
                return try Service<Self>(url: string)
            } catch {
                throw .malformedRequest(error.localizedDescription)
            }
        }
        
        static func networkProvider() async -> Network {
            await Network(override: .connected)
        }
    }
    
    enum Disconnected: ServiceProvider {
        typealias ErrorBodyType = ErrorBody
        
        static func route(_ string: String) throws(NetworkingError) -> Service<Self> {
            do {
                return try Service<Self>(url: string)
            } catch {
                throw .malformedRequest(error.localizedDescription)
            }
        }
        
        static func checksForConnectivity() -> Bool {
            return true
        }
        
        static func networkProvider() async -> Network {
            await Network(override: .disconnected)
        }
    }
    
    enum NotChecking: ServiceProvider {
        typealias ErrorBodyType = ErrorBody
        
        static func route(_ string: String) throws(NetworkingError) -> Service<Self> {
            do {
                return try Service<Self>(url: string)
            } catch {
                throw .malformedRequest(error.localizedDescription)
            }
        }
        
        static func checksForConnectivity() -> Bool {
            return false
        }
    }
    
    enum NotReachable: ServiceProvider {
        typealias ErrorBodyType = ErrorBody
        
        static func route(_ string: String) throws(NetworkingError) -> Service<Self> {
            do {
                return try Service<Self>(url: string)
            } catch {
                throw .malformedRequest(error.localizedDescription)
            }
        }
        
        static func networkProvider() async -> Network {
            await Network(override: .notReachable)
        }
    }
}

struct ErrorBody: Decodable, Sendable {
    let error: String
}
