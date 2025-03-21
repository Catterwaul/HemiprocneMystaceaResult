# Mapping Methods

##### General transformation

Transforming a value, by applying a function to it using dot syntax, is sometimes an easier-to-read way to write code, and probably ought to be available on *every type*: 

```swift
func transform<Transformed, Error>(
  _ transform: (Self) throws(Error) -> Transformed
) throws(Error) -> Transformed {
  try transform(self)
}
```

But that's not specific to `Result`, and is not included in this package.

We *could* restrict the transformation to require mapping similar types of `Result`s, such as 

`Result<Int, Never>` ➡️ `Result<String, any Error>`.

That would look like this:

```swift
func transform<NewSuccess, NewFailure, Error>(
  _ transform: (Self) throws(Error) -> Result<NewSuccess, NewFailure>
) throws(Error) -> Result<NewSuccess, NewFailure> {
  try transform(self)
}
```

Even with this new restriction, the possibilities are so vast in what can be accomplished there, that it's not worth creating a function for. And so again, this `transform` is not included in this package either.

### flatMap

`flatMap` is the closest to a general-purpose `transform` method that this package works with. The capabilities are different in only two respects: 

1. `flatMap`'s' `transform` closure operates only on a wrapped value, instead of an entire `Result` instance.

2. `flatMap` cannot modify the wrapped error type.

---

The "`flat`" in `flatMap` refers to the way that it introduces no more "nesting" than the `Result` represented before transformation. For example, 

```swift
Result<String, Never>.flatMap
```
, when supplied with a `transform` closure returning type 

```swift
Result<Int, Never>
```
, will return 

```swift
Result<Int, Never>
```
, as opposed to an "unflattened"

```swift
Result<Result<Int, Never>, Never>
```

---

[As documented below](doc:Swift/Result/flatMap(_:)), `flatMap` will not throw an error when the transformed `Result` is a `failure`, but it will throw an error if the transformation throws an error.

[The standard library](https://developer.apple.com/documentation/swift/result/flatMap(_:)) nearly gets `flatMap` right, but it does not incorporate throwing an error. This version should be deprecated.

### flatMapAndMergeError

This is a special case of `flatMap`. If `transform` throws the untransformed `Result`'s `Failure` type, the error can be forwarded into the transformed `Result` type, rather than being thrown from `flatMap`. 

Both forms are useful. Naming this differently than `flatMap` is necessary because it would not be enough, for the compiler, to just add `try` in front of another `flatMap` overload.

### map

The only difference between `flatMap` and `map` is that map's `transform` closure returns a `Success`, not a `Result`. Thusly, no "flattening" is necessary. 

As with `flatMap`, [the standard library](https://developer.apple.com/documentation/swift/result/map(_:)) nearly gets `map` right, but it does not incorporate throwing an error. This version should be deprecated.

### mapAndMergeError

This is to `map` as `flatMapAndMergeError` is to `flatMap`.

### flatMapFailure

This is the same idea as `flatMap`, except, with a transformation of the `Result`'s `Failure` type, rather than its `Success` type.

As we've seen above with `flatMap` and `map`, the standard library nearly gets this right, under the problematic* name [`flatMapError`](https://developer.apple.com/documentation/swift/result/flatMapError(_:)), but it does not incorporate throwing an error. It *should*, for completeness, but does anyone need that? 🤔 (It won't be included in this package until we hear that they do.)

\* It's problematic because the failure type, while restricted to be an error, is called `Failure`, not `Error`. And it's not clear whether you're mapping a failure enumeration case, or an error occurring from the transformation closure. 

### mapFailure

This is to `flatMapFailure` as `map` is to `flatMap`.

### mapFailureToSuccess

This idea only works when the `Failure` type is going to be "removed", which is represented by `Never`. So, there's no point in offering a `flatMapFailureToSuccess`, as `Result.failure`s can't be created with if their `Failure` is `Never`.

### mapFailureToSuccessAndErrorToFailure

This is a niche type of error mapping operation.  

It's similar to the two "`…AndMergeError`" methods in that an error thrown from transforming will become a `failure`.

But it's dissimilar in that while the error thrown *can* be `Failure`, there's no requirement of that (and it's likely to be a rare case). So, calling this `mapFailureToSuccessAndMergeError` would not generally be accurate.

## Topics

- ``Swift/Result/flatMap(_:)``
- ``Swift/Result/flatMapAndMergeError(_:)``
- ``Swift/Result/map(_:)``
- ``Swift/Result/mapAndMergeError(_:)``
- ``Swift/Result/mapFailureToSuccess(_:)``
- ``Swift/Result/mapFailureToSuccessAndErrorToFailure(_:)``
