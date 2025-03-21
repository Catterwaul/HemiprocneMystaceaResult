// MARK: - public
public extension Result where Success: ~Copyable {
  /// Creates a new result by evaluating a throwing closure, capturing the
  /// returned value as a success, or any thrown error as a failure.
  ///
  /// - Parameter body: A potentially throwing asynchronous closure to evaluate.
  @inlinable init(catching body: () async throws(Failure) -> Success) async {
    do { self = .success(try await body()) }
    catch { self = .failure(error) }
  }
}

public extension Result {
  /// Exchange a tuple of `Result`s for a single `Result` whose `Success` is a tuple.
  /// - Returns: `.failure` with the first failure that might occur in a tuple.
  @inlinable static func zip<each _Success>(
    _ result: (repeat Result<each _Success, Failure>)
  ) -> Self
  where Success == (repeat each _Success) {
    .init { () throws(_) in (repeat try (each result).get()) }
  }
}
