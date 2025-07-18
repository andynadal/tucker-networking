//
//  File.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

import Foundation

public extension Service {
    func get<D: Decodable>() async throws -> D {
        await setup()
        request.httpMethod = "GET"
        prettyPrint(request: request)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            prettyPrint(response: httpResponse)
            printAndSerialize(.response, json: data)
            do {
                switch httpResponse.statusCode {
                case 200..<300:
                    break
                default:
                    let error = try Provider.decoder().decode(Provider.ErrorBodyType.self, from: data)
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
    
    func get() async throws {
        await setup()
        request.httpMethod = "GET"
        prettyPrint(request: request)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            prettyPrint(response: httpResponse)
            printAndSerialize(.response, json: data)
            do {
                switch httpResponse.statusCode {
                case 200..<300:
                    break
                default:
                    let error = try Provider.decoder().decode(Provider.ErrorBodyType.self, from: data)
                    throw NetworkingError.invalidResponse(.init(code: httpResponse.statusCode, body: error))
                }
            } catch {
                throw error
            }
        }
    }
}
