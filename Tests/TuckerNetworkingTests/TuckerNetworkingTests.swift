import Testing
import Foundation
@testable import TuckerNetworking

enum Backend: ServiceProvider {
    typealias ErrorBodyType = ErrorBody
    
    static func useHeaders() async throws -> [TuckerNetworking.Header] {
        [
            Header(header: "Authorization", value: "Bearer \(TestToken.token)")
        ]
    }
    
    static func route(_ string: String) throws -> Service<Self> {
        try .init(url: "https://backend-git-main-pausa.vercel.app/api/v1\(string)")
    }
    
    static func decoder() -> JSONDecoder {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    static func encoder() -> JSONEncoder {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)
        encoder.outputFormatting = [.prettyPrinted]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

struct ErrorBody: Decodable, Sendable {
    let error: String
}

struct Streak: Decodable {
    let id: String
    let createdAt: Date
    let lastSession: Date
    let streakCount: Int
    let userId: String
}

@Test func testStreaks() async throws {
    let data: Streak = try await Backend.route("/streak")
        .get()
    print("Data", data)
}

enum TestToken {
    static let token = "eyJhbGciOiJIUzI1NiIsImtpZCI6Im50VUhFMHpWVC9vU0l0VTYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2lzZW9qZHJkdHpzcG1ucGV2Y2l6LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiJiMDg3MDk1Mi03Y2UyLTQ1YzItOTdlZC03ZDViZDI2MzgxMmMiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzUyMTg2OTM5LCJpYXQiOjE3NTIxODMzMzksImVtYWlsIjoibmFkYWxAcGF1c2FhcHAuY29tIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwidXNlcl9tZXRhZGF0YSI6eyJlbWFpbF92ZXJpZmllZCI6dHJ1ZX0sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3NTIxODMzMzl9XSwic2Vzc2lvbl9pZCI6IjVjMmQ4YzY4LTUzMTctNGZhMC05MjQ1LWRlMmU0MDZmN2E1NyIsImlzX2Fub255bW91cyI6ZmFsc2V9.fBYxlKQuqe3xHIgUDHruVuTsGioDru0SqSGPeYzZDrE"
}
