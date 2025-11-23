//
//  File.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

import Foundation

public extension Service {
    func get<D: Decodable>() async throws -> D {
        try await setup()
        request.httpMethod = "GET"
        prettyPrint(request: request)
        let (data, response) = try await Provider.session().data(for: request)
        try process(data, and: response)
        return try decode(data: data)
    }
    
    func get() async throws {
        try await setup()
        request.httpMethod = "GET"
        prettyPrint(request: request)
        let (data, response) = try await Provider.session().data(for: request)
        try process(data, and: response)
    }
}
