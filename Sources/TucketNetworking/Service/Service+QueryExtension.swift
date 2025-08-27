//
//  Service+QueryExtension.swift
//  TuckerNetworking
//
//  Created by Andy Nadal on 8/27/25.
//

import Foundation

public extension Service {
    func query<Q: Encodable>(_ query: Q) -> Self {
        guard let currentURL = request.url else { return self }
        
        do {
            // Create URLComponents from the current URL
            guard var components = URLComponents(url: currentURL, resolvingAgainstBaseURL: true) else { return self }
            
            // Get query items using our custom encoder that preserves type information
            let queryItems = try URLQueryItemEncoder.encode(query)
            guard !queryItems.isEmpty else { return self }
            
            // Append new query items to existing ones if any
            if components.queryItems != nil {
                components.queryItems?.append(contentsOf: queryItems)
            } else {
                components.queryItems = queryItems
            }
            
            // Update the URL in the request
            if let newURL = components.url {
                request.url = newURL
            }
        } catch {
            print("Failed to encode query parameters: \(error.localizedDescription)")
        }
        
        return self
    }
}

// MARK: - URLQueryItemEncoder

/// Encoder that converts an `Encodable` object to `[URLQueryItem]` while preserving type information
struct URLQueryItemEncoder {
    static func encode<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        let encoder = QueryEncoder()
        try value.encode(to: encoder)
        return encoder.queryItems
    }
}

private class QueryEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var queryItems: [URLQueryItem] = []
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = QueryKeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = QueryUnkeyedEncodingContainer(encoder: self)
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = QuerySingleValueEncodingContainer(encoder: self)
        return container
    }
}

private struct QueryKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    var codingPath: [CodingKey] = []
    var encoder: QueryEncoder
    
    // Encode all primitive types directly to String for URL query parameters
    mutating func encodeNil(forKey key: K) throws {
        // Skip nil values in URL queries
    }
    
    mutating func encode(_ value: Bool, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: value ? "true" : "false"))
    }
    
    mutating func encode(_ value: Int, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: Int8, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: Int16, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: Int32, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: Int64, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: UInt, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: UInt8, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: UInt16, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: UInt32, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: UInt64, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: Float, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: Double, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: String(value)))
    }
    
    mutating func encode(_ value: String, forKey key: K) throws {
        encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: value))
    }
    
    // Handle nested containers and encodable objects
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        // For simplicity, not supporting nested containers, but could be implemented with key path notation
        fatalError("Nested containers not supported for URL query encoding")
    }
    
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        // For simplicity, not supporting unkeyed containers
        fatalError("Unkeyed containers not supported for URL query encoding")
    }
    
    mutating func superEncoder() -> Encoder {
        return encoder
    }
    
    mutating func superEncoder(forKey key: K) -> Encoder {
        return encoder
    }
    
    mutating func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        // For primitive types that are directly Encodable, we should have handled them above
        // For custom Encodable types, we encode them as separate query parameters
        
        // Special case for Date objects
        if let date = value as? Date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            let dateString = formatter.string(from: date)
            encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: dateString))
            return
        }
        
        // Special case for URL objects
        if let url = value as? URL {
            encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: url.absoluteString))
            return
        }
        
        // Special handling for arrays of strings, which is the most common case
        if let stringArray = value as? [String] {
            let joinedValue = stringArray.joined(separator: ",")
            encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: joinedValue))
            return
        }
        // Handle arrays of other primitive types
        else if let intArray = value as? [Int] {
            let joinedValue = intArray.map { String($0) }.joined(separator: ",")
            encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: joinedValue))
            return
        }
        else if let doubleArray = value as? [Double] {
            let joinedValue = doubleArray.map { String($0) }.joined(separator: ",")
            encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: joinedValue))
            return
        }
        else if let boolArray = value as? [Bool] {
            let joinedValue = boolArray.map { $0 ? "true" : "false" }.joined(separator: ",")
            encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: joinedValue))
            return
        }
        // For other array types, use the unkeyed container approach
        else if Mirror(reflecting: value).displayStyle == .collection {
            let childEncoder = QueryEncoder()
            childEncoder.codingPath = codingPath + [key]
            try value.encode(to: childEncoder)
            
            // For array encoding, we use indexed values from the unkeyed container
            if !childEncoder.queryItems.isEmpty {
                // Convert the numeric indices back to proper values
                let arrayValues = childEncoder.queryItems.sorted { Int($0.name) ?? 0 < Int($1.name) ?? 0 }
                                               .compactMap { $0.value }
                let joinedValue = arrayValues.joined(separator: ",")
                encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: joinedValue))
            }
            return
        }
        
        // For other custom types, create a nested encoder with a path prefix
        let childEncoder = QueryEncoder()
        childEncoder.codingPath = codingPath + [key]
        try value.encode(to: childEncoder)
        
        // If it's a simple type, it will have produced a single query item
        if childEncoder.queryItems.count == 1 && childEncoder.queryItems[0].name.isEmpty {
            encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: childEncoder.queryItems[0].value))
        } else if !childEncoder.queryItems.isEmpty {
            // For nested objects, we have two options:
            // 1. Flatten the structure with dot notation: parent.child
            // 2. Serialize to JSON
            
            // Option 2: Serialize to JSON for simplicity
            // First try to convert the object to a dictionary
            do {
                // Convert the value to JSON data
                let jsonData = try JSONEncoder().encode(value)
                // Then to a string
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    encoder.queryItems.append(URLQueryItem(name: key.stringValue, value: jsonString))
                    return
                }
            } catch {
                // If JSON encoding fails, fall back to adding all items with dot notation
                for item in childEncoder.queryItems {
                    let nestedKey = item.name.isEmpty ? key.stringValue : "\(key.stringValue).\(item.name)"
                    encoder.queryItems.append(URLQueryItem(name: nestedKey, value: item.value))
                }
            }
        }
    }
}

// MARK: - QueryUnkeyedEncodingContainer

private struct QueryUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int = 0
    var encoder: QueryEncoder
    
    init(encoder: QueryEncoder) {
        self.encoder = encoder
    }
    
    mutating func encodeNil() throws {
        // Skip nil values
    }
    
    mutating func encode<T>(_ value: T) throws where T: Encodable {
        // Encode the value and add it to the query items with an indexed key
        if let stringValue = value as? String {
            encoder.queryItems.append(URLQueryItem(name: String(count), value: stringValue))
        } else if let boolValue = value as? Bool {
            encoder.queryItems.append(URLQueryItem(name: String(count), value: boolValue ? "true" : "false"))
        } else if let intValue = value as? Int {
            encoder.queryItems.append(URLQueryItem(name: String(count), value: String(intValue)))
        } else if let doubleValue = value as? Double {
            encoder.queryItems.append(URLQueryItem(name: String(count), value: String(doubleValue)))
        } else if let floatValue = value as? Float {
            encoder.queryItems.append(URLQueryItem(name: String(count), value: String(floatValue)))
        } else if let date = value as? Date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            let dateString = formatter.string(from: date)
            encoder.queryItems.append(URLQueryItem(name: String(count), value: dateString))
        } else if let url = value as? URL {
            encoder.queryItems.append(URLQueryItem(name: String(count), value: url.absoluteString))
        } else {
            // For complex types, use a nested encoder
            let childEncoder = QueryEncoder()
            try value.encode(to: childEncoder)
            
            if let queryItem = childEncoder.queryItems.first {
                encoder.queryItems.append(URLQueryItem(name: String(count), value: queryItem.value))
            }
        }
        
        count += 1
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = QueryKeyedEncodingContainer<NestedKey>(encoder: encoder)
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return QueryUnkeyedEncodingContainer(encoder: encoder)
    }
    
    mutating func superEncoder() -> Encoder {
        return encoder
    }
}

// MARK: - QuerySingleValueEncodingContainer

private struct QuerySingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey] = []
    var encoder: QueryEncoder
    
    init(encoder: QueryEncoder) {
        self.encoder = encoder
    }
    
    mutating func encodeNil() throws {
        // Skip nil values
    }
    
    mutating func encode(_ value: Bool) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: value ? "true" : "false"))
    }
    
    mutating func encode(_ value: String) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: value))
    }
    
    mutating func encode(_ value: Double) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: Float) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: Int) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: Int8) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: Int16) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: Int32) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: Int64) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: UInt) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: UInt8) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: UInt16) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: UInt32) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode(_ value: UInt64) throws {
        encoder.queryItems.append(URLQueryItem(name: "", value: String(value)))
    }
    
    mutating func encode<T>(_ value: T) throws where T: Encodable {
        // For custom Encodable types
        if let date = value as? Date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            let dateString = formatter.string(from: date)
            encoder.queryItems.append(URLQueryItem(name: "", value: dateString))
        } else if let url = value as? URL {
            encoder.queryItems.append(URLQueryItem(name: "", value: url.absoluteString))
        } else {
            // For other types, create a nested encoder
            try value.encode(to: encoder)
        }
    }
}

