import Foundation
import Logging

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

private let logger = Logger(label: "URLSession.data")

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let fullfillCompletetionOnTheMainThread: (Result<Data, Error>) -> Void  = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data, let response = response as? HTTPURLResponse {

                if 200..<300 ~= response.statusCode {
                    fullfillCompletetionOnTheMainThread(.success(data))
                } else {
                    logger.error("NetworkError.httpStatusCode - \(response.statusCode), URL: \(request.url?.absoluteString ?? "nil")")
                    fullfillCompletetionOnTheMainThread(
                        .failure(NetworkError.httpStatusCode(response.statusCode))
                    )
                }

            } else if let error {
                logger.error("NetworkError.urlRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "nil")")
                fullfillCompletetionOnTheMainThread(
                    .failure(NetworkError.urlRequestError(error))
                )
            } else {
                logger.error("NetworkError.urlSessionError - unknown session error, URL: \(request.url?.absoluteString ?? "nil")")
                fullfillCompletetionOnTheMainThread(
                    .failure(NetworkError.urlSessionError)
                )
            }
        }
        
        return task
    }
}
