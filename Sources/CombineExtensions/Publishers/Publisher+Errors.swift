#if canImport(Combine)
import Combine

extension Publisher {
	/// Erases typed error to Swift.Error
	@inlinable
	public func eraseError() -> some Publisher<Output, Error> {
		self.mapError { $0 as Error }
	}

	/// Repaces Failure with Output
	///
	/// Example:
	/// ```swift
	/// // Nice-to-have functional helper
	/// // tho such helpers are oos of combine-extensions
	/// func const<each Arg, T>(_ value: T) -> (repeat each Arg) -> T {
	/// 	return { (_: repeat each Arg) in value }
	/// }
	///
	/// failingIntPublisher.replaceError(with: const(0))
	/// ```
	@inlinable
	public func replaceError(
		with transform: @escaping (Failure) -> Output
	) -> some Publisher<Output, Never> {
		self.catch { Just(transform($0)) }
	}

	/// Emit nothing on failure
	@inlinable
	public func ignoreError() -> some Publisher<Output, Never> {
		self.catch { _ in Empty() }
	}
}
#endif
