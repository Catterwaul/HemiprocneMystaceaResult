// MARK: - public
public extension Result {
  /// Performs a failure-coalescing operation, returning the `success` value of a
  /// `Result` instance or a default value.
  ///
  /// - Bug: `defaultValue` should be an `@autoclosure`, but it  doesn't work with typed errors.
  @inlinable static func ?? <Error>(
    result: Self,
    defaultValue: () throws(Error) -> Success
  ) throws(Error) -> Success {
    do { return try result.get() }
    catch { return try defaultValue() }
  }

  /// Performs a failure-coalescing operation, returning the `success` value of a
  /// `Result` instance or a default value.
  @inlinable static func ?? (
    result: Self,
    defaultValue: @autoclosure () -> Success
  ) -> Success {
    do { return try result.get() }
    catch { return defaultValue() }
  }

  /// Exchange a tuple of `Result`s for a single `Result` whose `Success` is a tuple.
  /// - Returns: `.failure` with the first failure that might occur in a tuple.
  @inlinable static func zip<each _Success>(
    _ result: (repeat Result<each _Success, Failure>)
  ) -> Self
  where Success == (repeat each _Success) {
    .init { () throws(_) in (repeat try (each result).get()) }
  }

  /// Creates a new result by evaluating a throwing closure, capturing the
  /// returned value as a success, or any thrown error as a failure.
  ///
  /// - Parameter body: A potentially throwing asynchronous closure to evaluate.
  @inlinable init(catching body: () async throws(Failure) -> Success) async {
    do { self = .success(try await body()) }
    catch { self = .failure(error) }
  }
}
