#if canImport(Combine)
import Combine
import Foundation

/// Subjectt that is not a Publisher
public struct SubjectProxy<Output, Failure: Error> {
	@usableFromInline
	internal let underlyingSubject: any Subject<Output, Failure>

	public init<S: Subject>(_ subject: S) where S.Output == Output, S.Failure == Failure {
		self.underlyingSubject = subject
	}

	@inlinable
	public func send(_ value: Output) {
		underlyingSubject.send(value)
	}

	@inlinable
	public func send(subscription: Subscription) {
		underlyingSubject.send(subscription: subscription)
	}

	@inlinable
	public func send(completion: Subscribers.Completion<Failure>) {
		underlyingSubject.send(completion: completion)
	}

	@_spi(Internals)
	public func eraseToAnySubject() -> AnySubject<Output, Failure> {
		.init(self.underlyingSubject)
	}
}
#endif
