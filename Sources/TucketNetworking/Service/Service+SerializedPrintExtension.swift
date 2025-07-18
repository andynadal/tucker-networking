//
//  Service+SerializedPrintExtension.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

import Foundation

extension Service {
    enum Serialization {
        case body
        case response
        
        var startLabel: String {
            switch self {
            case .body:
                "-> body"
            case .response:
                "<- response"
            }
        }
        
        var endLabel: String {
            switch self {
            case .body:
                "-> end body"
            case .response:
                "<- end response"
            }
        }
    }
    
    func printAndSerialize(_ serialization: Serialization, json: Data) {
        do {
            let object = try JSONSerialization.jsonObject(with: json, options: [])
            let compactData = try JSONSerialization.data(withJSONObject: object, options: [])
            if let jsonString = String(data: compactData, encoding: .utf8) {
                print(serialization.startLabel)
                print(jsonString)
                print(serialization.endLabel)
            } else {
                print("Invalid UTF-8")
            }
        } catch {
            print("Couldn't serialize JSON:", error)
        }
    }

}

extension Service {
    func prettyPrint(request: URLRequest) {
        print("-> Sending Request --")
        print("-> \(request.httpMethod ?? "No HTTP Method") | \(request.url?.absoluteString ?? "No URL")")
        for header in request.allHTTPHeaderFields ?? [:] {
            if ["authorization", "api-key"].contains(header.key.lowercased()) {
                print("-- \(header): *****")
            }
            print("-> \(header.key): \(header.value)")
        }
        if let body = request.httpBody {
            printAndSerialize(.body, json: body)
        }
    }
}

extension Service {
    func prettyPrint(response: HTTPURLResponse) {
        print("<- Receiving Response --")
        print("<- \(response.statusCode) | \(response.url?.absoluteString ?? "No URL")")
    }
}
