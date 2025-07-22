// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// An instance of a service, used in each network call
public actor Service<Provider: ServiceProvider> {
    
    var request: URLRequest
    
    public init(url: String) throws {
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
    
    public func add(header: String, value: String) {
        request.addValue(value, forHTTPHeaderField: "Authorization")
    }
    
    func process(_ data: Data, and response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
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
    
    func decode<D: Decodable>(data: Data) throws -> D {
        do {
            let body = try Provider.decoder().decode(D.self, from: data)
            return body
        } catch {
            throw error
        }
    }
}
