import Foundation
import UIKit

extension REST {
	public class SafeCourier<D: Decodable>: Courier<D> {
		public func get(parcel: Parcel<D>, on path: String, with parameters: Serialization, then complete: @escaping ([D]) -> Void) {
			get(parcel: parcel, on: path, with: parameters, then: { (result, response, error) in
				if let r = result { complete(r) }
			})
		}
		
		public func post(parcel: Parcel<D>, on path: String, with parameters: Serialization, then complete: @escaping ([D]) -> Void) {
			post(parcel: parcel, on: path, with: parameters, then: { (result, response, error) in
				if let r = result { complete(r) }
			})
		}

		private func get(parcel: Parcel<D>, on path: String, with parameters: Serialization, then complete: @escaping ([D]?, URLResponse?, Error?) -> Void) {
			let s = path + "?" + parameters.asHttpQuery
			var r = URLRequest(url: parcel.path(s))
			r.httpMethod = "GET"
			
			r.addValue("application/json", forHTTPHeaderField: "Content-Type")
			r.addValue("application/json", forHTTPHeaderField: "Accept")
			
			carry(parcel: parcel, for: r, then: complete)
		}

		private func post(parcel: Parcel<D>, on path: String, with parameters: Serialization, then complete: @escaping ([D]?, URLResponse?, Error?) -> Void) {
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

	
	public class Courier<D: Decodable> {
		func carry(parcel: Parcel<D>, for request: URLRequest, then complete: @escaping ([D]?, URLResponse?, Error?) -> Void) {
			let c = URLSessionConfiguration.ephemeral
			let s = URLSession(configuration: c, delegate: nil, delegateQueue: OperationQueue.main)
			let t = s.dataTask(with: request) { data, response, error in
				if error != nil { print("Buruwa.REST Error: \(error!.localizedDescription)") }
				
				guard let d = data else {
					print("Buruwa.REST Error: did not receive data")
					complete(nil, response, error)
					return
				}
				
				let r = parcel.resources(from: d)
				complete(r, response, error)
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
