import HMError
import Testing

extension ResultTests.Map {
  struct FailureToSuccess { }
}

extension ResultTests.Map.FailureToSuccess {
  @Test func standard() throws {
    try test(Result.mapFailureToSuccess) { mappedFailure in
      _ = try mappedFailure()
      fatalError()
    }
  }

  @Test func errorToFailure() throws {
    try test(Result.mapFailureToSuccessAndErrorToFailure) { mappedFailure in
      _ = try mappedFailure().get()
      fatalError()
    }
  }
}

// MARK: - private
private extension ResultTests.Map.FailureToSuccess {
  private typealias Result = Swift.Result<String, SomeError>

  private func test<Error, NewFailure>(
    _ map: @escaping (Result) ->
    ((SomeError) throws(String?.Nil) -> String)
    throws(Error) -> Swift.Result<String, NewFailure>,
    handleError: (() throws(Error) -> Swift.Result<String, NewFailure>) throws(Error) -> Void
  ) throws {
    typealias Nil = String?.Nil

    var transformed: Optional = "transformed"
    func transform(_: some Swift.Error) throws(Nil) -> String {
      try transformed.get() ¿! Nil.self
    }

    successToSuccess: do {
      let success = "success"
      let result = Result.success("success")
      #expect(try map(result)(transform).get() == success)
    }

    let failure: Result = .failure(.init())
    failureToSuccess: do {
      let result = try map(failure)(transform)
      #expect(try result.get() == transformed)
    }
    failure: do {
      transformed = nil
      #expect(throws: nil as Nil) {
        try handleError { () throws(_) in try map(failure)(transform) }
      }
    }
  }
}
