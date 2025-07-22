import Testing
import Foundation
@testable import TuckerNetworking

@Suite("restful-api.dev | Real API Suite")
struct RealSuite {
    @Test func testGetObjects() async throws {
        let data: [Response] = try await TestProvider.route("/objects")
            .get()
        assert(data.count > 0)
    }
    
    @Test func testGetObjectsWithoutParsingResponse() async throws {
        try await TestProvider.route("/objects")
            .get()
    }

    @Test func testPostObject() async throws {
        let data: Response = try await TestProvider.route("/objects")
            .post(body: Request(name: "iPhone", data: nil))
        assert(data.name == "iPhone")
    }
    
    @Test func testPostObjectWithoutParsingResponse() async throws {
        try await TestProvider.route("/objects")
            .post(body: Request(name: "iPhone", data: nil))
    }
    
    @Test func testPutObject() async throws {
        let data: Response = try await TestProvider.route("/objects")
            .post(body: Request(name: "iPhone", data: nil))
        let response: Response = try await TestProvider.route("/objects/\(data.id)")
            .put(body: Request(name: "Mac", data: nil))
        assert(response.name == "Mac")
    }
    
    @Test func testPatchObject() async throws {
        let data: Response = try await TestProvider.route("/objects")
            .post(body: Request(name: "iPhone", data: nil))
        let response: Response = try await TestProvider.route("/objects/\(data.id)")
            .patch(body: Request(name: "Mac", data: nil))
        assert(response.name == "Mac")
    }
    
    @Test func testDeleteObject() async throws {
        let data: Response = try await TestProvider.route("/objects")
            .post(body: Request(name: "iPhone", data: nil))
        try await TestProvider.route("/objects/\(data.id)")
            .delete()
        await #expect(throws: NetworkingError.self) {
            try await TestProvider.route("/objects/\(data.id)")
                .get()
        }
    }
}

extension RealSuite {
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
            [
                .init(header: "Content-Type", value: "application/json")
            ]
        }
    }

    struct ErrorBody: Decodable, Sendable {
        let error: String
    }

    struct Response: Decodable {
        let id: String
        let name: String
        let data: Metadata?
    }
    
    struct Request: Encodable {
        let name: String
        let data: Metadata?
    }

    struct Metadata: Codable {
        let color: String?
        let capacity: String?
        let price: Double?
    }

}
