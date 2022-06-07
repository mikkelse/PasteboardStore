# PasteboardStore

A wrapper around UIPasteboard which allows reading and writing a **Payload** to the pasteboard.

The payload is encoded into JSON data and then base64 encoded into a string set as a query parameter to a URL stored in the pasteboard with **identifier** as the host.

This allows for limited short term sharing of a data between apps, to facility "over the app store" installs for example. 

##Example use##

````Swift
// Create some data,
let data = "Some data".data(using: .utf8)!

// Initialize payload.
let payload = Payload(
    data: data,
    date: Date(),
    backLink: URL(string: "https://www.myapp.com")!
)

do {
    // Create pasteboard with identifier. Here using the apple id of the app.
    let store = PasteboardStore(identifier: "id319104329")

    // Write payload to pasteboard
    try store.writePayload(payload)

    // Read the payload from pasteboard.
    guard let payload1 = try store.readPayload() else { print("Payload not found"); return }
    print("Before clear: " + String(data: payload1.data, encoding: .utf8)!)

    // Clear the payload from pasteboard.
    store.clearPayload()

    guard let payload2 = try store.readPayload() else { print("Payload not found"); return }
    print("After clear: " + String(data: payload2.data, encoding: .utf8)!)
} catch {
    print("Failed to read/write payload: \(error)")
}
````
