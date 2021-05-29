//
//  Request.swift
//  Created by Shawn Throop on 29.05.21.
//

import Foundation
import Combine

public struct Request: Equatable {
    
    public struct Environment: Equatable {
        
        public var base = URLComponents()
        
        public init(scheme: String = "https", host: String, path: String = "", queryItems: [URLQueryItem] = []) {
            base.scheme = scheme
            base.host = host
            base.path = path
            base.queryItems = queryItems
        }
    }
    
    public enum Method: String, Hashable {
        case get, head, post, put, delete, connect, options, trace
    }
    
    public enum Body: Equatable {
        case raw(Data)
        case stream(InputStream)
        
        public static func json<Value: Encodable>(_ value: Value, encoder: JSONEncoder = .init()) throws -> Self {
            try .raw(encoder.encode(value))
        }
    }
    
    
    public var environment: Environment
    public var method: Method
    public var path: String
    public var query: [URLQueryItem]
    public var headers: [HeaderField: String]
    public var body: Body?
    
    public init(to environment: Environment, method: Method = .get, path: String, query: [URLQueryItem] = [], headers: [HeaderField: String] = [:], body: Body? = nil) {
        self.environment = environment
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
    }
    
    
    public func publisher(using session: URLSession = .shared) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        session
            .dataTaskPublisher(for: URLRequest(self))
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw URLError(.cannotParseResponse)
                }
                
                return (data, response)
            }
            .eraseToAnyPublisher()
    }
}


extension URLRequest {
    
    public init(_ request: Request) {
        var components = request.environment.base
        components.path += request.path
        
        var items = components.queryItems ?? []
        items.append(contentsOf: request.query)
        components.queryItems = items
        
        guard let url = components.url else {
            fatalError("cannot create URL from components: \(components)")
        }
        
        self.init(url: url)
        httpMethod = request.method.rawValue.uppercased()
        
        for (field, value) in request.headers {
            addValue(value, forHTTPHeaderField: field.rawValue)
        }
        
        switch request.body {
        case .raw(let data):
            httpBody = data
        case .stream(let stream):
            httpBodyStream = stream
            
        default:
            break
        }
    }
}
