#if canImport(Combine)
import Combine
import Foundation

/// Witness type for `any Subject<Output, Failure>` protocol
public class AnySubject<Output, Failure: Error>: Subject {
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

	@inlinable
	public func receive<S>(subscriber: S)
	where S: Subscriber, Failure == S.Failure, Output == S.Input {
		underlyingSubject.receive(subscriber: subscriber)
	}
}

extension AnySubject {
	/// Creates an instance with an underlying PublishSubject
	@inlinable
	public static func publish() -> AnySubject {
		.init(PublishSubject())
	}

	/// Creates an instance with an underlying PublishSubject with initial value
	@inlinable
	public static func publish(_ initialValue: Output) -> AnySubject {
		.init(PublishSubject(initialValue))
	}

	/// Creates an instance with an underlying PassthroughSubject
	@inlinable
	public static func passthrough() -> AnySubject {
		.init(PassthroughSubject())
	}

	/// Creates an instance with an underlying CurrentValueSubject
	@inlinable
	public static func currentValue(_ initialValue: Output) -> AnySubject {
		.init(CurrentValueSubject(initialValue))
	}
}

extension Subject {
	/// Erases the instance to AnySubject
	public func eraseToAnySubject() -> AnySubject<Output, Failure> {
		return AnySubject(self)
	}
}
#endif
