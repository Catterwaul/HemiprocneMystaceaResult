private import HMCodable

// MARK: - Encodable
extension Result: @retroactive Encodable where Success: Encodable, Failure: Encodable {
  public func encode(to encoder: any Encoder) throws {
    switch self {
    case .success(let success): try encoder.encode((CodingKey.success, success))
    case .failure(let failure): try encoder.encode((CodingKey.failure, failure))
    }
  }
}

// MARK: - Decodable
extension Result: @retroactive Decodable where Success: Decodable, Failure: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    do { self = .success(try container[.success]) }
    catch { self = .failure(try container[.failure]) }
  }
}

// MARK: - private
private extension Result {
  enum CodingKey: Swift.CodingKey {
    case success, failure
  }
}
