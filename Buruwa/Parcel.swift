import Foundation

extension REST {
	open class Parcel: NSObject {
		open func resources<R: Codable>(from data: Data) -> [R]? {
			do {
				if String(data: data, encoding: .utf8)!.first == "[" {
					let s = try decoder.decode([R].self, from: data)
					return s
				} else {
					let s = try decoder.decode(R.self, from: data)
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

		public var courier = SafeCourier()

		func path(_ path: String) -> URL {return URL(string: path)! }
	}
}
