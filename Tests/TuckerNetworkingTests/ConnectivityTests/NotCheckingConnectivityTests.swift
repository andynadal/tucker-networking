//
//  File.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 11/23/25.
//

import Testing
import Foundation
@testable import TuckerNetworking

@Suite("Not Checking Connectivity")
@MainActor
struct NotCheckingConnectivityTests {
    @Test func testGETReturnsNetworkOverrideError() async throws {
        let service = try Service<ConnectivityProvider.NotChecking>(url: "https://example.com/api/search")
        #expect(await service.checkConnectivity == false)
    }
}
