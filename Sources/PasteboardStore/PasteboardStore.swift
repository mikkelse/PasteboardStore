//
//  PasteboardStore.swift
//  Unleashd
//
//  Created by Mikkel Sindberg Eriksen on 07/06/2022.
//

import Foundation
import UIKit

/// A type that can read and write a payload to the pasteboard.
public struct PasteboardStore<P: Codable> {

    /// The identifier to use for referenceing the payload in the pasteboard.
    public let identifier: String

    /// Initialize the store with the given identifer.
    public init(identifier: String) {
        self.identifier = identifier
    }

    /// Read a payload associated with the store's identifier in the pasteboard.
    /// - returns nil if no payload was found associated with the given identifier
    /// - throws if a payload was found, but there was an issue de-serializing it from the pasteboard.
    public func readPayload() throws -> P? {
        return try PasteboardStore.readPayload(for: identifier)
    }

    /// Write a payload to the pasteboard, associating it with the store's identifier.
    /// - throws if there was an issue writing the payload to the pasteboard.
    public func writePayload(_ payload: P) throws {
        try PasteboardStore.write(payload, with: identifier)
    }

    /// Clear the payload from the pasteboard.
    public func clearPayload() {
        PasteboardStore.clearPayload()
    }
}

extension PasteboardStore {

    private static func write(_ payload: P, with identifier: String) throws {
        let base64Payload = try payload.toData().base64EncodedString()
        UIPasteboard.general.string = "\(base64Payload).\(identifier)"
    }

    private static func readPayload(for identifier: String) throws -> P? {
        guard
            let content = UIPasteboard.general.string, content.contains(identifier),
            let encodedPayload = content.components(separatedBy: ".").first,
            let data = Data.init(base64Encoded: encodedPayload)
        else { return nil }
        return try P(from: data)
    }

    private static func clearPayload() {
        UIPasteboard.general.string = ""
    }
}

extension Encodable {

    func toData() throws -> Data {
        let encoder = JSONEncoder.init()
        return try encoder.encode(self)
    }
}

extension Decodable {

    init(from data: Data) throws {
        let decoder = JSONDecoder.init()
        self = try decoder.decode(Self.self, from: data)
    }
}
