import Foundation
import UIKit

extension REST {
	public class SafeCourier: Courier {
		public func get<R: Decodable>(parcel: Parcel, on path: String, with parameters: Serialization, then complete: @escaping ([R]) -> Void) {
			get(parcel: parcel, on: path, with: parameters, then: { (result: [R]?, response: URLResponse?, error: Error?) in
				if let r = result { complete(r) }
			})
		}

		public func post<P: Encodable, R: Decodable>(parcel: Parcel, on path: String, with parameters: P, then complete: @escaping ([R]) -> Void) {
			post(parcel: parcel, on: path, with: parameters, then: { (result: [R]?, response: URLResponse?, error: Error?) in
				if let r = result { complete(r) }
			})
		}

		public func post<R: Decodable>(parcel: Parcel, on path: String, with parameters: Serialization, then complete: @escaping ([R]) -> Void) {
			post(parcel: parcel, on: path, with: parameters, then: { (result: [R]?, response: URLResponse?, error: Error?) in
				if let r = result { complete(r) }
			})
		}

		public func post(parcel: Parcel, on path: String, with parameters: Serialization, then complete: @escaping () -> Void) {
			post(parcel: parcel, on: path, with: parameters, then: { (response: URLResponse?, error: Error?) in
				complete()
			})
		}

		private func get<R: Decodable>(parcel: Parcel, on path: String, with parameters: Serialization, then complete: @escaping ([R]?, URLResponse?, Error?) -> Void) {
			let s = path + "?" + parameters.asHttpQuery
			var r = URLRequest(url: parcel.path(s))
			r.httpMethod = "GET"
			
			r.addValue("application/json", forHTTPHeaderField: "Content-Type")
			r.addValue("application/json", forHTTPHeaderField: "Accept")
			
			carry(parcel: parcel, for: r, then: complete)
		}

		private func post<P: Encodable, R: Decodable>(parcel: Parcel, on path: String, with parameters: P, then complete: @escaping ([R]?, URLResponse?, Error?) -> Void) {
			var r = URLRequest(url: parcel.path(path))
			r.httpMethod = "POST"
			
			r.addValue("application/json", forHTTPHeaderField: "Content-Type")
			r.addValue("application/json", forHTTPHeaderField: "Accept")
			
			r.httpBody = parcel.data(from: parameters)
			carry(parcel: parcel, for: r, then: complete)
		}

		private func post<R: Decodable>(parcel: Parcel, on path: String, with parameters: Serialization, then complete: @escaping ([R]?, URLResponse?, Error?) -> Void) {
			var r = URLRequest(url: parcel.path(path))
			r.httpMethod = "POST"
			
			r.addValue("application/json", forHTTPHeaderField: "Content-Type")
			r.addValue("application/json", forHTTPHeaderField: "Accept")
			
			do { r.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) }
			catch let error { print(error.localizedDescription) }
			carry(parcel: parcel, for: r, then: complete)
		}

		private func post(parcel: Parcel, on path: String, with parameters: Serialization, then complete: @escaping (URLResponse?, Error?) -> Void) {
			var r = URLRequest(url: parcel.path(path))
			r.httpMethod = "POST"
			
			r.addValue("application/json", forHTTPHeaderField: "Content-Type")
			r.addValue("application/json", forHTTPHeaderField: "Accept")
			
			do { r.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) }
			catch let error { print(error.localizedDescription) }
			carry(parcel: parcel, for: r, then: complete)
		}

		override public init() {}
	}

	
	public class Courier {
		func carry<R: Decodable>(parcel: Parcel, for request: URLRequest, then complete: @escaping ([R]?, URLResponse?, Error?) -> Void) {
			let c = URLSessionConfiguration.ephemeral
			let s = URLSession(configuration: c, delegate: nil, delegateQueue: OperationQueue.main)
			let t = s.dataTask(with: request) { data, response, error in
				if error != nil { print("Buruwa.REST Error: \(error!.localizedDescription)") }
				
				guard let d = data else {
					print("Buruwa.REST Error: did not receive data")
					complete(nil, response, error)
					return
				}
				
				let r: [R]? = parcel.resources(from: d)
				complete(r, response, error)
			}
			t.resume()
		}

		func carry(parcel: Parcel, for request: URLRequest, then complete: @escaping (URLResponse?, Error?) -> Void) {
			let c = URLSessionConfiguration.ephemeral
			let s = URLSession(configuration: c, delegate: nil, delegateQueue: OperationQueue.main)
			let t = s.dataTask(with: request) { data, response, error in
				if error != nil { print("Buruwa.REST Error: \(error!.localizedDescription)") }
				
				complete(response, error)
			}
			t.resume()
		}
	}
}


public typealias Serialization = [String: Any]

extension Serialization {
	var asHttpQuery: String {
		return map {
			let p = $0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
			let v = (String(describing: $0.value)).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
			return "\(p)=\(v)"
			}.joined(separator: "&")
	}
}


extension String {
	public var httpSafe: String {
		return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
	}
}
