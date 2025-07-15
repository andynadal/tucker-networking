//
//  Service+PostExtension.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

import Foundation

public extension Service {
    func post<R: Encodable, D: Decodable>(body: R) async throws -> D {
        await setup()
        request.httpMethod = "POST"
        request.httpBody = try Provider.encoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        printAndSerialize(json: data)
        if let httpResponse = response as? HTTPURLResponse {
            do {
                switch httpResponse.statusCode {
                case 200..<300:
                    break
                default:
                    let error = try Provider.decoder().decode(Provider.ErrorBodyType.self, from: data)
                    printAndSerialize(json: data)
                    throw NetworkingError.invalidResponse(.init(code: httpResponse.statusCode, body: error))
                }
            } catch {
                throw error
            }
        }
        do {
            let body = try Provider.decoder().decode(D.self, from: data)
            return body
        } catch {
            throw error
        }
    }
}
