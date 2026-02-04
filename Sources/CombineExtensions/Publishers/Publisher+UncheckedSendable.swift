#if canImport(Combine)
import Combine

extension Publisher {
	/// Makes publisher @unchecked Sendable
	@inlinable
	public func uncheckedSendable() -> some Publisher<Output, Failure> & Sendable {
		UncheckedSendablePublisher(self)
	}
}

@usableFromInline
internal struct UncheckedSendablePublisher<P: Publisher>: Publisher, @unchecked Sendable {
	@usableFromInline
	typealias Output = P.Output

	@usableFromInline
	typealias Failure = P.Failure

	private let publisher: P

	@usableFromInline
	internal init(_ publisher: P) {
		self.publisher = publisher
	}

	@usableFromInline
	internal func receive<S>(subscriber: S) where S : Subscriber, P.Failure == S.Failure, P.Output == S.Input {
		publisher.receive(subscriber: subscriber)
	}
}
#endif
