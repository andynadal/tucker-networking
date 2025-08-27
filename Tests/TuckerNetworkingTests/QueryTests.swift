import Testing
import Foundation
@testable import TuckerNetworking

@Suite("Query Parameters Tests")
struct QueryTests {
    @Test func testSimpleQueryParameters() async throws {
        // Create a service directly with a test URL
        let service = try Service<EmptyProvider>(url: "https://example.com/api/search")
        
        // Define simple query parameters
        let queryParams = SimpleQuery(term: "swift", page: 1)
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Verify URL construction
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Convert to dictionary for easier testing
        let queryDict = queryItemsToDict(queryItems)
        
        // Assert that parameters are present with correct values
        assert(queryDict["term"] == "swift")
        assert(queryDict["page"] == "1")
        
        // Verify the base URL is preserved
        assert(components?.scheme == "https")
        assert(components?.host == "example.com")
        assert(components?.path == "/api/search")
    }
    
    @Test func testComplexQueryParameters() async throws {
        // Create a service directly with a test URL
        let service = try Service<EmptyProvider>(url: "https://example.com/api/products")
        
        // Define complex query parameters with different types
        let queryParams = ComplexQuery(
            searchTerm: "iPhone", 
            maxPrice: 1000.50, 
            inStock: true, 
            minRating: 4,
            categories: ["electronics", "phones"]
        )
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        print("THE URL TO TEST IS", url)
        
        // Verify URL construction
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Convert to dictionary for easier testing
        let queryDict = queryItemsToDict(queryItems)
        
        // Assert that parameters are present with correct values
        assert(queryDict["searchTerm"] == "iPhone")
        assert(queryDict["maxPrice"] == "1000.5")
        assert(queryDict["inStock"] == "true")
        assert(queryDict["minRating"] == "4")
        // Note: categories array will be encoded in some JSON form
        assert(queryDict["categories"] != nil)
        
        // Verify the base URL is preserved
        assert(components?.scheme == "https")
        assert(components?.host == "example.com")
        assert(components?.path == "/api/products")
    }
    
    @Test func testPreservingExistingQueryParameters() async throws {
        // Create a service with a URL that already has query parameters
        let service = try Service<EmptyProvider>(url: "https://example.com/api/search?sort=desc&limit=10")
        
        // Define additional query parameters
        let queryParams = SimpleQuery(term: "swift", page: 1)
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Verify URL construction
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Convert to dictionary for easier testing
        let queryDict = queryItemsToDict(queryItems)
        
        // Assert that both original and new parameters are present
        assert(queryDict["sort"] == "desc")
        assert(queryDict["limit"] == "10")
        assert(queryDict["term"] == "swift")
        assert(queryDict["page"] == "1")
        
        // Verify the URL has all parameters (4)
        assert(queryItems.count == 4)
    }
    
    @Test func testEmptyQueryObject() async throws {
        // Create a service
        let service = try Service<EmptyProvider>(url: "https://example.com/api")
        
        // Define empty query parameters object
        let queryParams = EmptyQuery()
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Verify URL construction - should remain unchanged
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        // The URL should not have any query parameters
        assert(components?.queryItems == nil || components?.queryItems?.isEmpty == true)
        
        // Base URL should be preserved
        assert(url.absoluteString == "https://example.com/api")
    }
    
    @Test func testSpecialCharactersInQueryParameters() async throws {
        // Create a service
        let service = try Service<EmptyProvider>(url: "https://example.com/api/search")
        
        // Define query parameters with special characters
        let queryParams = SpecialCharQuery(
            term: "hello world & more!",
            filter: "category:books+games"
        )
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Decode the query parameters to check proper encoding
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Get the raw values (already decoded by URLComponents)
        let queryDict = queryItemsToDict(queryItems)
        
        // Verify the values are preserved after URL encoding/decoding
        assert(queryDict["term"] == "hello world & more!")
        assert(queryDict["filter"] == "category:books+games")
    }
    
    @Test func testNilOptionalParameters() async throws {
        // Create a service
        let service = try Service<EmptyProvider>(url: "https://example.com/api/search")
        
        // Define query parameters with optional values
        let queryParams = OptionalQuery(
            required: "main",
            optional1: nil,
            optional2: "present"
        )
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Get components and query items
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Convert to dictionary for testing
        let queryDict = queryItemsToDict(queryItems)
        
        // Verify that only non-nil parameters are included
        assert(queryDict["required"] == "main")
        assert(queryDict["optional1"] == nil) // Should not be present
        assert(queryDict["optional2"] == "present")
        
        // There should be only 2 query items
        assert(queryItems.count == 2)
    }
    
    @Test func testNestedObjectParameters() async throws {
        // Create a service
        let service = try Service<EmptyProvider>(url: "https://example.com/api")
        
        // Define nested query parameters
        let address = NestedAddress(
            street: "123 Main St",
            city: "San Francisco",
            zipCode: "94105"
        )
        let queryParams = NestedQuery(
            name: "John",
            address: address
        )
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Get query parameters
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Convert to dictionary for testing
        let queryDict = queryItemsToDict(queryItems)
        
        // Verify that the main parameter exists
        assert(queryDict["name"] == "John")
        
        // The nested object should be encoded somehow (could be JSON)
        // Just verify that there's a parameter for the address
        assert(queryDict["address"] != nil)
    }
    
    @Test func testArrayParameters() async throws {
        // Create a service
        let service = try Service<EmptyProvider>(url: "https://example.com/api")
        
        // Define query parameters with an array
        let queryParams = ArrayQuery(
            tags: ["swift", "ios", "programming"]
        )
        
        // Apply query parameters and get the resulting URL
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Get query parameters
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Convert to dictionary for testing
        let queryDict = queryItemsToDict(queryItems)
        
        // Verify that the tags parameter exists
        assert(queryDict["tags"] != nil)
        
        // The actual encoding format could vary (JSON array)
        // We're just ensuring it was included
    }
    
    @Test func testMultipleQueryCalls() async throws {
        // Create a service
        let service = try Service<EmptyProvider>(url: "https://example.com/api")
        
        // Apply first query
        _ = await service.queryAndExposeUrl(SimpleQuery(term: "first", page: 1))
        
        // Apply second query (should append, not replace)
        let url = await service.queryAndExposeUrl(SimpleQuery(term: "second", page: 2))
        
        // Get query parameters
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // There should be 4 parameters (2 from each query)
        // The exact behavior may depend on implementation (replace vs. append)
        assert(queryItems.count >= 2)
    }
    
    @Test func testNonASCIICharacters() async throws {
        // Create a service
        let service = try Service<EmptyProvider>(url: "https://example.com/api")
        
        // Define query with non-ASCII characters
        let queryParams = SpecialCharQuery(
            term: "こんにちは", // Japanese "hello"
            filter: "café☕️" // Non-ASCII and emoji
        )
        
        // Apply query parameters
        let url = await service.queryAndExposeUrl(queryParams)
        
        // Get decoded query parameters
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        // Convert to dictionary for testing
        let queryDict = queryItemsToDict(queryItems)
        
        // Verify the values are preserved after URL encoding/decoding
        assert(queryDict["term"] == "こんにちは")
        assert(queryDict["filter"] == "café☕️")
    }
    
    // Helper function to convert query items to a dictionary
    func queryItemsToDict(_ items: [URLQueryItem]) -> [String: String] {
        var dict = [String: String]()
        for item in items {
            dict[item.name] = item.value
        }
        return dict
    }
}

extension QueryTests {
    // Empty Provider for testing query functionality without making actual API calls
    enum EmptyProvider: ServiceProvider {
        typealias ErrorBodyType = ErrorBody
        
        static func route(_ string: String) throws(NetworkingError) -> Service<Self> {
            do {
                return try Service<Self>(url: string)
            } catch {
                throw .malformedRequest(error.localizedDescription)
            }
        }
        
        struct ErrorBody: Decodable, Sendable {
            let error: String
        }

        static func useHeaders() async throws(NetworkingError) -> [Header] {
            [
                .init(header: "Content-Type", value: "application/json")
            ]
        }
    }

    // Test Query Models
    struct SimpleQuery: Encodable {
        let term: String
        let page: Int
    }
    
    struct ComplexQuery: Encodable {
        let searchTerm: String
        let maxPrice: Double
        let inStock: Bool
        let minRating: Int
        let categories: [String]
    }
    
    struct EmptyQuery: Encodable {
        // Empty query object for testing
    }
    
    struct SpecialCharQuery: Encodable {
        let term: String
        let filter: String
    }
    
    struct OptionalQuery: Encodable {
        let required: String
        let optional1: String?
        let optional2: String?
    }
    
    struct NestedAddress: Encodable {
        let street: String
        let city: String
        let zipCode: String
    }
    
    struct NestedQuery: Encodable {
        let name: String
        let address: NestedAddress
    }
    
    struct ArrayQuery: Encodable {
        let tags: [String]
    }
    
    struct ErrorStub: Codable, Sendable {
        let message: String
    }
}
