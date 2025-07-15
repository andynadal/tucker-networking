//
//  File.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

import Foundation

public struct ErrorWrapper: Sendable {
    public let code: Int
    public let body: any Decodable & Sendable
}
