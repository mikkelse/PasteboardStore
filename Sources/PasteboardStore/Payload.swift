//
//  Payload.swift
//  
//
//  Created by Mikkel Sindberg Eriksen on 07/06/2022.
//

import Foundation

/// A type representing a payload to store data on the pasteboard.
public struct Payload: Codable {

    /// The data of the payload, to store on the pasteboard.
    public let data: Data

    /// The date of when the payload was created.
    public let date: Date

    /// The link leading back to the app that created the payload.
    public let backLink: URL
}

extension Payload {

    /// Encode the payload as json data.
    func toData() throws -> Data {
        let encoder = JSONEncoder.init()
        return try encoder.encode(self)
    }

    /// Initialize the payload from the given json data.
    init(from data: Data) throws {
        let decoder = JSONDecoder.init()
        self = try decoder.decode(Payload.self, from: data)
    }
}

