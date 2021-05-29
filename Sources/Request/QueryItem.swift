//
//  QueryItem.swift
//  Created by Shawn Throop on 30.05.21.
//

import Foundation

public protocol QueryItem {
    
    var name: String { get }
}


extension Request.Body {
    
    public static func urlEncoded<Key: Hashable & QueryItem>(_ query: [Key: String]) -> Self? {
        var components = URLComponents()
        components.queryItems = .init(query)
        
        guard let data = components.query?.data(using: .utf8) else {
            return nil
        }
        
        return .raw(data)
    }
}


extension QueryItem where Self: RawRepresentable, RawValue == String {
    
    public var name: String { rawValue }
}


extension Array where Element == URLQueryItem {
    
    public init<Key: QueryItem>(_ query: [Key: String]) {
        self = query.map { URLQueryItem(name: $0.key.name, value: $0.value) }
    }
}
