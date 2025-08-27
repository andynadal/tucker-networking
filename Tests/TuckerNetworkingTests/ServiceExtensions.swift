import Foundation
@testable import TuckerNetworking

// Test extension to expose internal URL after query parameters are applied
extension Service {
    func queryAndExposeUrl<Q: Encodable>(_ query: Q) async -> URL {
        // Apply query parameters
        _ = self.query(query)
        
        // Return the resulting URL
        return request.url ?? URL(string: "about:blank")!
    }
    
    // Helper method to create a URL request with query parameters
    func createRequestWithQuery<Q: Encodable>(_ query: Q) async -> URLRequest {
        _ = self.query(query)
        return self.request
    }
    
    // Helper method to extract just the query string part
    func getQueryString<Q: Encodable>(_ query: Q) async -> String? {
        await self.queryAndExposeUrl(query).query
    }
}
