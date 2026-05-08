import Foundation
import Logging


private let logger = Logger(label: "URLSession.data")

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void  = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data, let response = response as? HTTPURLResponse {

                if 200..<300 ~= response.statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    logger.error("[data]: NetworkError.httpStatusCode - \(response.statusCode), URL: \(request.url?.absoluteString ?? "nil")")
                    fulfillCompletionOnTheMainThread(
                        .failure(NetworkError.httpStatusCode(response.statusCode))
                    )
                }

            } else if let error {
                logger.error("[data]: NetworkError.urlRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "nil")")
                fulfillCompletionOnTheMainThread(
                    .failure(NetworkError.urlRequestError(error))
                )
            } else {
                logger.error("[data]: NetworkError.urlSessionError - unknown session error, URL: \(request.url?.absoluteString ?? "nil")")
                fulfillCompletionOnTheMainThread(
                    .failure(NetworkError.urlSessionError)
                )
            }
        }
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        data(for: request) { result in
            switch (result) {
            case .success(let data):
                do {
                    let object = try JSONDecoder.snakeCase.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    logger.error("[objectTask]: NetworkError.decodingError - \(error.localizedDescription), type: \(T.self), data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
