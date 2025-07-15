//
//  NetworkingError.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

public enum NetworkingError: Error {
    case malformedRequest(String)
    case invalidResponse(ErrorWrapper)
}
