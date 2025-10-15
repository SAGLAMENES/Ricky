import Foundation

public extension URLRequest {
    func prettyDescription() -> String {
        """
        [Request]
        URL: \(url?.absoluteString ?? "")
        Method: \(httpMethod ?? "")
        Headers: \(allHTTPHeaderFields ?? [:])
        """
    }
}