//
//  Service+SerializedPrintExtension.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 7/15/25.
//

import Foundation

extension Service {
    func printAndSerialize(json: Data) {
        do {
            let object = try JSONSerialization.jsonObject(with: json, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
            debugPrint(String(data: prettyData, encoding: .utf8) ?? "No JSON")
        } catch {
            print("Couldn't pretty print JSON", error)
        }
    }
}
