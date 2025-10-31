# Networking

Networking tools.

## `getUsingJSON`

`getUsingJSON` is an easy-to-use synchronous function that allows you to virtually pass one structure to a network service in order to receive another structure back.

The function adapts to the type of the input and the type of the receiver.

Sample code which uses an assumed JSON-REST interface to an SQL database:

```swift
struct SQLRequest: Encodable {
    let sql: String
}

struct SQLResponse<Item: Decodable>: Decodable {
    let databaseError: String?
    let items: [Item]?
}

struct Person: Decodable {
    let forename: String
    let surname: String
}

let url = URL(string: "http://127.0.0.1:8080")!

let sqlRequest = SQLRequest(sql: "SELECT * FROM person WHERE surname LIKE 'Wal%'")

let result: SQLResponse<Person> = try getUsingJSON(
    for: sqlRequest,
    from: url,
    withTimeoutInSeconds: 2.0
)
```
