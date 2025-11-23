//
//  File.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/22/25.
//

public extension Service {
    func put<R: Encodable, D: Decodable>(body: R) async throws -> D {
        try await setup()
        request.httpMethod = "PUT"
        request.httpBody = try Provider.encoder().encode(body)
        prettyPrint(request: request)
        let (data, response) = try await Provider.session().data(for: request)
        try process(data, and: response)
        return try decode(data: data)
    }
    
    func put<R: Encodable>(body: R) async throws {
        try await setup()
        request.httpMethod = "PUT"
        request.httpBody = try Provider.encoder().encode(body)
        prettyPrint(request: request)
        let (data, response) = try await Provider.session().data(for: request)
        try process(data, and: response)
    }
}
