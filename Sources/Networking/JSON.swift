import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct JSONCommunicationError: Error, CustomStringConvertible  {
    
    public let description: String
    
    public var localizedDescription: String { description }
    
    public init(_ description: String) {
        self.description = description
    }
    
}

fileprivate final class Result: @unchecked Sendable {
    var errorText: String? = nil
    var data: Data? = nil
}

/// This is a synchronous function that allows you to virtually pass one structure to a network service in order to receive another structure back.
public func getUsingJSON<RequestData: Encodable, ReponseData: Decodable>(
    for requestData: RequestData,
    from url: URL,
    usingHTTPMethod httpMethod: String? = "POST",
    withTimeoutInSeconds timeoutInSeconds: Double
) throws -> ReponseData {
    
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.addValue( "application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = httpMethod
    request.httpBody = try JSONEncoder().encode(requestData)
    
    let group = DispatchGroup()
    group.enter()
    
    let result = Result()
    
    let webTask = session.dataTask(with: request) { serverData, response, error in
        
        if let error {
            result.errorText = error.localizedDescription
            group.leave(); return
        }
        
        guard let serverData else {
            result.errorText = "server did not return any data"
            group.leave(); return
        }
        
        result.data = serverData
        
        group.leave()
    }
    
    webTask.resume()
    
    let timeoutResult = group.wait(timeout: .now() + timeoutInSeconds)
    if timeoutResult == .timedOut {
        throw JSONCommunicationError("\(url): timeout")
    }
    
    if let errorText = result.errorText {
        throw JSONCommunicationError(("\(url): \(errorText)"))
    } else if let data = result.data {
        do {
            return try JSONDecoder().decode(ReponseData.self, from: data)
        } catch {
            throw JSONCommunicationError("\(url): \(error)")
        }
    } else {
        throw JSONCommunicationError("\(url): resulting data missing unexpectedly")
    }
}
