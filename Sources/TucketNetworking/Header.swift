//
//  Header.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

public struct Header {
    public init(header: String, value: String) {
        self.header = header
        self.value = value
    }
    
    public var header: String
    public var value: String
}
