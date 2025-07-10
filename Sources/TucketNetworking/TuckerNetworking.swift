// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

struct Header {
    var header: String
    var value: String
}

protocol ServiceProvider: Sendable {
    static func useHeaders() async throws -> [Header]
    static func decoder() -> JSONDecoder
    static func encoder() -> JSONEncoder
    static func route(_ string: String) throws -> Service<Self>
    
    associatedtype ErrorBodyType: Decodable & Sendable
}

actor Service<Provider: ServiceProvider> {
    init(url: String) throws {
        guard let url = URL(string: url) else { throw NetworkingError.malformedRequest("Invalid URL") }
        self.request = URLRequest(url: url)
    }
    
    func setup() async {
        do {
            for header in try await Provider.useHeaders() {
                self.request.addValue(header.value, forHTTPHeaderField: header.header)
            }
        } catch {
            
        }
    }
    
    var request: URLRequest
    
    func add(header: String, value: String) {
        request.addValue(value, forHTTPHeaderField: "Authorization")
    }
    
    func get<D: Decodable>() async throws -> D {
        await setup()
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        printAndSerialize(json: data)
        if let httpResponse = response as? HTTPURLResponse {
            do {
                print("Status code: \(httpResponse.statusCode)")
                switch httpResponse.statusCode {
                case 200..<300:
                    break
                default:
                    let error = try Provider.decoder().decode(Provider.ErrorBodyType.self, from: data)
                    printAndSerialize(json: data)
                    throw NetworkingError.invalidResponse(.init(code: httpResponse.statusCode, body: error))
                }
            } catch {
                print("Ha?")
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
    
    private func printAndSerialize(json: Data) {
        do {
            let object = try JSONSerialization.jsonObject(with: json, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
            debugPrint(String(data: prettyData, encoding: .utf8) ?? "No JSON")
        } catch {
            print("Couldn't pretty print JSON", error)
        }
    }
}

struct ErrorWrapper: Sendable {
    let code: Int
    let body: any Decodable & Sendable
}

enum NetworkingError: Error {
    case malformedRequest(String)
    case invalidResponse(ErrorWrapper)
}
