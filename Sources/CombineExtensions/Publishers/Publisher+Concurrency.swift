#if canImport(Combine)
import Combine

extension Publisher where Self: Sendable {
	/// Awaits publisher completion
	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	public func completion() async throws {
		for try await _ in values {}
		return
	}
}
#endif
