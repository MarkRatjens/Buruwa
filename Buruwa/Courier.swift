import Foundation
import UIKit

extension REST {
	public class Courier<D: Decodable> {
		open func carry(parcel: Parcel<D>, for request: URLRequest, then complete: @escaping ([D]?, URLResponse?, Error?) -> Void) {
			let c = URLSessionConfiguration.ephemeral
			let s = URLSession(configuration: c, delegate: nil, delegateQueue: OperationQueue.main)
			let t = s.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
				if error != nil { print("NyasaKit.REST Error: \(error!.localizedDescription)") }
				
				guard let d = data else {
					print("NyasaKit.REST Error: did not receive data")
					complete(nil, response, error)
					return
				}
				
				let r = parcel.resources(from: d)
				complete(r, response, error)
			})
			t.resume()
		}
	}

	
	public class SafeCourier<D: Decodable>: Courier<D> {
		public func carry(parcel: Parcel<D>, on path: String, with parameters: Serialization, then complete: @escaping ([D]?, URLResponse?, Error?) -> Void) {
			var r = URLRequest(url: parcel.path(path))
			r.httpMethod = "POST"
			
			r.addValue("application/json", forHTTPHeaderField: "Content-Type")
			r.addValue("application/json", forHTTPHeaderField: "Accept")
			
			do { r.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) }
			catch let error { print(error.localizedDescription) }
			carry(parcel: parcel, for: r, then: complete)
		}
	
		public func carry(parcel: Parcel<D>, on path: String, with parameters: Serialization, then complete: @escaping ([D]) -> Void) {
			carry(parcel: parcel, on: path, with: parameters, then: { (result: [D]?, response: URLResponse?, error: Error?) in
				if let r = result { complete(r) }
			})
		}
		
		override public init() {}
	}
}

public typealias Serialization = [String: Any]
