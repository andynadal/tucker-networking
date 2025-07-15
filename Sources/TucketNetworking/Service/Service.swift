// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// An instance of a service, used in each network call
public actor Service<Provider: ServiceProvider> {
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
    
    var request: URLRequest
    
    public func add(header: String, value: String) {
        request.addValue(value, forHTTPHeaderField: "Authorization")
    }
}
