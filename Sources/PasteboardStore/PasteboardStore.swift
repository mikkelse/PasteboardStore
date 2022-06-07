//
//  PasteboardStore.swift
//  Unleashd
//
//  Created by Mikkel Sindberg Eriksen on 07/06/2022.
//

import Foundation
import UIKit

/// A type that can read and write a payload to the pasteboard.
public struct PasteboardStore {

    public enum Error: Swift.Error { case internalError(String) }

    /// Initialize the store with the given identifer. 
    public init(identifier: String) {
        self.identifier = identifier
    }

    /// The identifier to use for referenceing the payload in the pasteboard.
    public let identifier: String

    /// Read a payload associated with the store's identifier in the pasteboard.
    /// - returns nil if no payload was found associated with the given identifier
    /// - throws if a payload was found, but there was an issue de-serializing it from the pasteboard.
    public func readPayload() throws -> Payload? {
        return try PasteboardStore.readPayload(for: identifier)
    }

    /// Write a payload to the pasteboard, associating it with the store's identifier.
    /// - throws if there was an issue writing the payload to the pasteboard.
    public func writePayload(_ payload: Payload) throws {
        try PasteboardStore.write(payload, with: identifier)
    }

    /// Clear the payload associated with the store's identifier from the pasteboard.
    public func clearPayload() {
        PasteboardStore.clearPayload(for: identifier)
    }
}

extension PasteboardStore {

    private static var encodedDataKey: String { "ed" }

    private static func data(from url: URL, with identifier: String) -> Data? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.host == identifier,
            let encodedString = (components.queryItems?.first { $0.name == encodedDataKey}?.value )
        else { return nil }
        return Data.init(base64Encoded: encodedString)
    }

    private static func url(with data: Data, identifier: String) -> URL? {
        let base64Encoded = data.base64EncodedString()
        var components = URLComponents()
        components.host = identifier
        components.queryItems = [URLQueryItem(name: encodedDataKey, value: base64Encoded)]
        return components.url
    }
}

extension PasteboardStore {

    private static func write(_ payload: Payload, with identifier: String) throws {
        guard let url = url(with: try payload.toData(), identifier: identifier) else {
            let message = "Failed to create pasteboard url from payload: \(payload), identifier: \(identifier)"
            throw Error.internalError(message)
        }
        UIPasteboard.general.urls = [url]
    }

    private static func readPayload(for identifier: String) throws -> Payload? {
        guard
            let pasteboardUrls = UIPasteboard.general.urls,
            let data = (pasteboardUrls.compactMap { data(from: $0, with: identifier) }).first
        else { return nil }
        return try Payload(from: data)
    }

    private static func clearPayload(for identifier: String) {
        let urls = UIPasteboard.general.urls?.filter{ $0.host != identifier }
        UIPasteboard.general.urls = urls
    }
}
