#if canImport(Combine)
import Combine

public class NonScopedCancellable: Cancellable {
	@inlinable
	public convenience init(_ cancellable: Cancellable) {
		self.init(cancellable.cancel)
	}
	
	public init(_ action: @escaping () -> Void) {
		self._action = action
	}
	
	internal let _action: () -> Void

	public func cancel() { _action() }
}
#endif
