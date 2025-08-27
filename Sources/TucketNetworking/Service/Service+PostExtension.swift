//
//  Service+PostExtension.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

public extension Service {
    func post<R: Encodable, D: Decodable>(body: R) async throws -> D {
        await setup()
        request.httpMethod = "POST"
        request.httpBody = try Provider.encoder().encode(body)
        prettyPrint(request: request)
        let (data, response) = try await Provider.session().data(for: request)
        try process(data, and: response)
        return try decode(data: data)
    }
    
    func post<R: Encodable>(body: R) async throws {
        await setup()
        request.httpMethod = "POST"
        request.httpBody = try Provider.encoder().encode(body)
        prettyPrint(request: request)
        let (data, response) = try await Provider.session().data(for: request)
        try process(data, and: response)
    }
    
    func post() async throws {
        await setup()
        request.httpMethod = "POST"
        prettyPrint(request: request)
        let (data, response) = try await Provider.session().data(for: request)
        try process(data, and: response)
    }
}
