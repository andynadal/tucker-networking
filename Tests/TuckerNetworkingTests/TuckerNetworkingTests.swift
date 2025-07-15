import Testing
import Foundation
@testable import TuckerNetworking

enum TestProvider: ServiceProvider {
    typealias ErrorBodyType = ErrorBody
    
    static func route(_ string: String) throws(NetworkingError) -> Service<Self> {
        do {
            return try Service<Self>(url: "https://api.restful-api.dev\(string)")
        } catch {
            throw .malformedRequest(error.localizedDescription)
        }
    }
}

struct ErrorBody: Decodable, Sendable {
    let error: String
}

struct Phone: Decodable {
    let id: String
    let name: String
    let data: PhoneMetadata?
}

struct PhoneMetadata: Decodable {
    let color: String?
    let capacity: String?
    let price: Double?
}

@Test func testGetObjects() async throws {
    let data: [Phone] = try await TestProvider.route("/objects")
        .get()
    print(data)
}
