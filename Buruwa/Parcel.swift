import Foundation

extension REST {
	open class Parcel<D: Decodable>: NSObject {
		open func resources(from data: Data) -> [D]? {
			do {
				if String(data: data, encoding: .utf8)!.first == "[" {
					let s = try decoder.decode([D].self, from: data)
					return s
				} else {
					let s = try decoder.decode(D.self, from: data)
					return [s]
				}
			}
			catch let error {
				print(error)
				return nil
			}
		}
		
		public var decoder: JSONDecoder {
			let d = JSONDecoder()
			d.dateDecodingStrategy = .iso8601
			return d
		}

		func path(_ path: String) -> URL {return URL(string: path)! }
	}
}
