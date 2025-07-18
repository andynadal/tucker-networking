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
    
    static func useHeaders() async throws(NetworkingError) -> [Header] {
        [.init(header: "Content-Type", value: "application/json")]
    }
}

struct ErrorBody: Decodable, Sendable {
    let error: String
}

struct Phone: Codable {
    let id: String
    let name: String
    let data: PhoneMetadata?
}

struct PhoneMetadata: Codable {
    let color: String?
    let capacity: String?
    let price: Double?
}

@Test func testGetObjects() async throws {
    let data: [Phone] = try await TestProvider.route("/objects")
        .get()
    assert(data.count > 0)
}

@Test func testPostObject() async throws {
    let data: Phone = try await TestProvider.route("/objects")
        .post(body: Phone(id: "0", name: "iPhone", data: nil))
    assert(data.name == "iPhone")
}

@Test func testGetObjectsWithoutParsingResponse() async throws {
    try await TestProvider.route("/objects")
        .get()
}

@Test func testPostObjectWithoutParsingResponse() async throws {
    try await TestProvider.route("/objects")
        .post(body: Phone(id: "0", name: "iPhone", data: nil))
}
