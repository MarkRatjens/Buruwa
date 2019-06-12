import Foundation

extension REST {
	open class Parcel<D: Decodable>: NSObject {
		open func resources(from data: Data) -> [D]? {
			do {
				let s = try decoder.decode(D.self, from: data)
				return [s]
			}
			catch {
				print("JSON root is not a valid object... continuing to process as an Array")
				do {
					let s = try decoder.decode([D].self, from: data)
					return s
				}
				catch let error {
					print(error)
					return nil
				}
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
