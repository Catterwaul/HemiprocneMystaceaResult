// MARK: - Mapping
public extension Result {
  /// Transform successes.
  /// - Throws: `Error`. If you instead want it to be stored in the new `Result`'s  `failure`,
  ///   you'll need ``flatMapAndMergeError(_:)``.
  /// - Note: Naming this differently than `flatMapAndMergeError`
  /// is necessary because it would not be enough, for the compiler,
  /// to just remove `try` from in front of another `flatMap` overload.
  @inlinable func flatMap<NewSuccess, Error>(
    _ transform: (Success) throws(Error) -> Result<NewSuccess, Failure>
  ) throws(Error) -> Result<NewSuccess, Failure> {
    switch self {
    case .success(let success): try transform(success)
    case .failure(let failure): .failure(failure)
    }
  }

  /// Transform successes.
  /// - Throws: `Never`. If `transform` throws an error, it will be stored in a `failure`.
  ///   If you want to throw the error instead,  you'll need ``flatMap(_:)``.
  /// - Note: Naming this differently than `flatMap`
  ///   is necessary because it would not be enough, for the compiler,
  ///   to just add `try` in front of a similarly-name overload.
  @inlinable func flatMapAndMergeError<NewSuccess>(
    _ transform: (Success) throws(Failure) -> Result<NewSuccess, Failure>
  ) -> Result<NewSuccess, Failure> {
    do { return try transform(get()) }
    catch { return .failure(error) }
  }

  /// Transform successes.
  /// - Throws: `Error`. If you instead want it to be stored in the new `Result`'s  `failure`,
  ///   you'll need ``mapAndMergeError(_:)``.
  /// - Note: Naming this differently than `mapAndMergeError`
  ///   is necessary because it would not be enough, for the compiler,
  ///   to just remove `try` from in front of another `map` overload.
  @inlinable func map<NewSuccess, Error>(
    _ transform: (Success) throws(Error) -> NewSuccess
  ) throws(Error) -> Result<NewSuccess, Failure> {
    try mapToSuccess(flatMap: flatMap, transform: transform)
  }

  /// Transform successes.
  /// - Throws: `Never`. If `transform` throws an error, it will be stored in a `failure`.
  ///   If you want to throw the error instead,  you'll need ``map(_:)``.
  /// - Note: Naming this differently than `map`
  ///   is necessary because it would not be enough, for the compiler,
  ///   to just add `try` in front of a similarly-name overload.
  @inlinable func mapAndMergeError<NewSuccess>(
    _ transform: (Success) throws(Failure) -> NewSuccess
  ) -> Result<NewSuccess, Failure> {
    mapToSuccess(flatMap: flatMapAndMergeError, transform: transform)
  }

  // MARK: - Failure != Never
  // These compile when Failure == Never, but will generate warnings,
  // and can't actually do anything, because a `Never` cannot be transformed.

  /// Transform failures into successes.
  /// - Throws: `Error`. If you instead want it to be stored in the new `Result`'s  `failure`,
  ///   you'll need ``mapFailureToSuccessAndErrorToFailure(_:)``.
  /// - Note: Naming this differently than `mapFailureToSuccessAndErrorToFailure`
  ///   is necessary because it would not be enough, for the compiler,
  ///   to just remove `try` from in front of another `mapFailureToSuccess` overload.
  @inlinable func mapFailureToSuccess<Error>(
    _ transform: (Failure) throws(Error) -> Success
  ) throws(Error) -> Result<Success, Never> {
    let success: Success
    do { success = try get() }
    catch { success = try transform(error) }
    return .success(success)
  }

  /// Transform failures into successes and errors into failures.
  /// - Throws: `Never`. If `transform` throws an error, it will be stored in a `failure`.
  ///   If you want to throw the error instead,  you'll need ``mapFailureToSuccess(_:)``.
  /// - Note: Naming this differently than `mapFailureToSuccess`
  ///   is necessary because it would not be enough, for the compiler,
  ///   to just add `try` in front of a similarly-name overload.
  @inlinable func mapFailureToSuccessAndErrorToFailure<Error>(
    _ transform: (Failure) throws(Error) -> Success
  ) -> Result<Success, Error> {
    do { return .success(try get()) }
    catch {
      return .init { () throws(_) in try transform(error) }
    }
  }
}

// MARK: - "private", but elevated to internal to be @inlinable
extension Result {
  /// Use the code from a `flatMap` for a `map`.
  @inlinable func mapToSuccess<Input, NewSuccess, NewFailure, TransformError, Error>(
    flatMap: ((Input) throws(TransformError) -> Result<NewSuccess, NewFailure>)
      throws(Error) -> Result<NewSuccess, NewFailure>,
    transform: (Input) throws(TransformError) -> NewSuccess
  ) throws(Error) -> Result<NewSuccess, NewFailure> {
    // This compiling may be a bug.
    // https://forums.swift.org/t/decorated-non-escaping-closures/70481/5
    let flatmap = flatMap

    return try flatmap { (input) throws(TransformError) in
      try .success(transform(input))
    }
  }
}
