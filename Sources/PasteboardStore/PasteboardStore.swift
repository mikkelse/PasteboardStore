//
//  PasteboardStore.swift
//
//  Created by Mikkel Sindberg Eriksen on 07/06/2022.
//

import UIKit

/// A type that can read and write a payload to the pasteboard.
public struct PasteboardStore<P: Codable> {

    /// The pasteboard type to use for storing the payload in the pasteboard. Usually, reverse domain name style.
    public let pasteBoardType: String

    /// Initialize the store with the given pasteboard type to use for storing a payload in the pasteboard..
    public init(pasteBoardType: String) {
        self.pasteBoardType = pasteBoardType
    }

    /// Read a payload associated with the store's pasteboard type.
    /// - returns nil if no payload was found for the pasteboard type of the store.
    /// - throws if a payload was found, but there was an issue de-serializing it from the pasteboard.
    public func readPayload() throws -> P? {
        return try PasteboardStore.readPayload(for: pasteBoardType)
    }

    /// Write a payload to the pasteboard, using the store's pasteboard type.
    /// - throws if there was an issue writing the payload to the pasteboard.
    public func writePayload(_ payload: P) throws {
        try PasteboardStore.write(payload, with: pasteBoardType)
    }

    /// Clear the payload from the pasteboard.
    public func clearPayload() {
        PasteboardStore.clearPayload()
    }
}

extension PasteboardStore {

    private static func write(_ payload: P, with type: String) throws {
        let payloadData = try payload.toData()
        UIPasteboard.general.setData(payloadData, forPasteboardType: type)
    }

    private static func readPayload(for type: String) throws -> P? {
        guard let payloadData = UIPasteboard.general.data(forPasteboardType: type) else { return nil }
        return try P(from: payloadData)
    }

    private static func clearPayload() {
        UIPasteboard.general.items = []
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
