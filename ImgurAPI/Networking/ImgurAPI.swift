//
//  ImgurAPI.swift
//  ImgurAPI
//
//  Created by Steven Chen on 2022/4/28.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case dataLoadingError(statusCode: Int, data: Data)
    case jsonDecodingError(error: Error)
}

final class ImgurAPI {
    
    // MARK: Properties
    
    private var session: URLSession
    private let baseURL = URL(string: "https://api.imgur.com/3")!
    private let clientID = "63911e965ccb361"
    
    
    // MARK: Initializers
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    // MARK: Helpers
    
    private func buildRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}

// MARK: Gallery Search Methods
extension ImgurAPI {
    
    enum GallerySearchSortingType: String {
        case time
        case viral
        case top
    }
    
    private func buildSearchGalleryRequest(page: Int, sort: GallerySearchSortingType, query: String) -> URLRequest? {
        let baseURL = baseURL.appendingPathComponent("/gallery/search")
            .appendingPathComponent(sort.rawValue)
            .appendingPathComponent(String(page))
        let parameters: [String : CustomStringConvertible] = ["q": query]
        
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = parameters.keys.map { key in
            URLQueryItem(name: key, value: parameters[key]?.description)
        }
        guard let url = components.url else {
            return nil
        }
        return buildRequest(url: url)
    }
    
    // https://apidocs.imgur.com/#3c981acf-47aa-488f-b068-269f65aee3ce
    public func searchGallery(query: String,
                              page: Int = 0,
                              sort: GallerySearchSortingType = .time,
                              completion: @escaping (Result<[Gallery]?, Error>) -> Void) {
        guard let request = buildSearchGalleryRequest(page: page, sort: sort, query: query) else {
            completion(.failure(NSError()))
            return
        }
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard let response = response as? HTTPURLResponse, let data = data, 200..<300 ~= response.statusCode else {
                completion(.failure(NSError()))
                return
            }
            do {
                let gallery = try JSONDecoder().decode(GallerySearchResult.self, from: data)
                completion(.success(gallery.galleries.filter{ $0.getFirstImageLink() != nil }))
            } catch {
               completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func searchGallery(query: String,
                              page: Int = 0,
                              sort: GallerySearchSortingType = .time) -> AnyPublisher<[Gallery]?, Error> {
        guard let request = buildSearchGalleryRequest(page: page, sort: sort, query: query) else {
            return .fail(NetworkError.invalidRequest)
        }
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.invalidRequest }
            .print()
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                guard let response = response as? HTTPURLResponse else {
                    return .fail(NetworkError.invalidResponse)
                }
                guard 200..<300 ~= response.statusCode else {
                    return .fail(NetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
                }
                return .just(data)
            }
            .decode(type: GallerySearchResult.self, decoder: JSONDecoder())
            .tryMap({ result in
                return result.galleries.filter { $0.getFirstImageLink() != nil }
            })
        .eraseToAnyPublisher()
    }
}
