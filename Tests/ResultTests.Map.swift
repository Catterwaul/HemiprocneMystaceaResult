import HMError
import Testing

extension ResultTests {
  struct Map { }
}

extension ResultTests.Map {
  @Test func standard() throws {
    typealias Result<Success> = Swift.Result<Success, SomeError>

    func test(_ map: (Result<String>) throws(Int?.Nil) -> Result<Int>) throws {
      try self.test(map, failure: .init()) { getResult in
        transformThrows: do {
          #expect(throws: nil as Int?.Nil) { try getResult() }
        }
      }
    }

    try test { result throws(_) in
      try result.flatMap { string throws(Int?.Nil) in
          .success(try transform(string))
      }
    }

    try test { result throws(_) in try result.map(transform) }
  }

  @Test func mergeError() throws {
    typealias Failure = Int?.Nil
    typealias Result<Success> = Swift.Result<Success, Failure>

    func test(_ map: (Result<String>) -> Result<Int>) throws {
      try self.test(map, failure: nil)
      transformMerges: do {
        let result = map(Result { "🏅" })
        #expect(throws: nil as Failure, performing: result.get)
      }
    }

    try test {
      $0.flatMapAndMergeError { string throws(_) in
          .success(try transform(string))
      }
    }
    try test { $0.mapAndMergeError(transform) }
  }
}

// MARK: - private
private extension ResultTests.Map {
  private func transform(_ string: String) throws(Int?.Nil) -> Int {
    try .init(string).get() ¿! Int?.Nil.self
  }

  private func test<Failure: Equatable, Error>(
    _ map: (Result<String, Failure>) throws(Error) -> Result<Int, Failure>,
    failure: Failure,
    testInvalidString: @escaping (() throws(Error) -> Result<Int, Failure>) -> Void
  ) throws {
    try test(map, failure: failure)
    self.testInvalidString(map, testInvalidString)
  }

  private func test<Failure: Equatable, Error>(
    _ map: (Result<String, Failure>) throws(Error) -> Result<Int, Failure>,
    failure: Failure
  ) throws {
    successToSuccess: do {
      let result = try map(.init { "1" })
      #expect(try result.get() == 1)
    }
    failurePropagates: do {
      let result = try map(Result.failure(failure))
      #expect(throws: failure, performing: result.get)
    }
  }

  /// - Bug: This is not callable from `mergeError`.
  private func testInvalidString<Failure: Equatable, Error>(
    _ map: (Result<String, Failure>) throws(Error) -> Result<Int, Failure>,
    _ testInvalidString: @escaping (() throws(Error) -> Result<Int, Failure>) -> Void
  ) {
    testInvalidString { () throws(_) in try map(.init { "🏅" }) }
  }
}
