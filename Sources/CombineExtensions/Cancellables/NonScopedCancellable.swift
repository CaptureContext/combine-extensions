#if canImport(Combine)
import Combine

/// Cancellable that is not cancelled on deinit
///
/// - Note: This wrapper does not modify the behavior
///         of nested cancellables, so if you wrap for example
///         `AnyCancellable`, it **will** be cancelled on deinit.
public class NonScopedCancellable: Cancellable {
	@inlinable
	public convenience init(_ cancellable: Cancellable) {
		self.init(cancellable.cancel)
	}
	
	public init(_ action: @escaping () -> Void) {
		self._action = action
	}

	@usableFromInline
	internal let _action: () -> Void

	@inlinable
	public func cancel() { _action() }
}
#endif
