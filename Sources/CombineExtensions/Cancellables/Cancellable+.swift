#if canImport(Combine)
import Combine

extension Cancellable {
	@inlinable
	public func eraseToAnyCancellable() -> AnyCancellable {
		return AnyCancellable(self)
	}
}
#endif
