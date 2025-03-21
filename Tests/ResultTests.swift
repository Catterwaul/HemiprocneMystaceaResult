import HMError
import HMResult
import Testing
import Foundation

struct ResultTests {
  @Test func `init`() async {
    func succeed() async throws(SomeError) { }
    var result = await Result<_, SomeError>(catching: succeed)
    #expect(throws: Never.self, performing: result.get)
    result = await .init { () async throws(_) in throw SomeError()  }
    #expect(throws: SomeError(), performing: result.get)
  }

  @Test func codable() throws {
    struct Failure: Error & Equatable & Codable { }
    typealias Result = Swift.Result<String, Failure>
    func test(_ result: Result, _ json: String) throws {
      let data = try JSONEncoder().encode(result)
      #expect(String(data: data, encoding: .utf8) == json)
      #expect(try JSONDecoder().decode(Result.self, from: data) == result)
    }
    try test(.success("🍀"), #"{"success":"🍀"}"#)
    try test(.failure(.init()), #"{"failure":{}}"#)
  }

  @Test func zip() throws {
    let jenies = (
      Result<_, String?.Nil>.success("👖"),
      Result<_, String?.Nil>.success("🧞‍♂️")
    )

    #expect(
      try Result.zip(jenies).get() == ("👖", "🧞‍♂️")
    )

    // `jenies` should be have been `var`,
    // and these blocks should not be necessary, but
    // https://github.com/apple/swift/issues/74425
    do {
      var jenies = jenies
      jenies.1 = .failure(nil)
      do {
        let jenies = jenies
        #expect(throws: String?.Nil.self) {
          try Result.zip(jenies).get()
        }
      }
    }
  }
}
