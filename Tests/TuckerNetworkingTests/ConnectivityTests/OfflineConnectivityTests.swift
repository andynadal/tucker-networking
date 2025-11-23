//
//  ConnectivityTests.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 11/23/25.
//

import Testing
import Foundation
@testable import TuckerNetworking

@Suite("Offline Connectivity")
@MainActor
struct OfflineConnectivityTests {
    @Test func testGETReturnsNetworkError() async throws {
        await #expect(throws: NetworkingError.self) {
            try await Service<ConnectivityProvider.Disconnected>(url: "https://example.com/api/search")
                .get()
        }
    }
    
    @Test func testGETReturnsNetworkOverrideError() async throws {
        let service = try await Service<ConnectivityProvider.Disconnected>(url: "https://example.com/api/search")
            .doesNotCheckConnectivity()
        #expect(await service.checkConnectivity == false)
    }
}
