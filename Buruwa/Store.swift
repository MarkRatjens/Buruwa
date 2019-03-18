public struct REST {
	open class Store: NSObject {
		public var decoder: JSONDecoder {
			let d = JSONDecoder()
			d.dateDecodingStrategy = .iso8601
			return d
		}
	}
}
