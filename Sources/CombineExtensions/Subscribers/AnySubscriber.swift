#if canImport(Combine)
import Combine
import Foundation

public struct AnySubscriber<Input, Failure: Error>: Subscriber {
	@usableFromInline
	internal let underlyingSubscriber: any Subscriber<Input, Failure>

	public init<S: Subscriber>(_ subscriber: S) where S.Input == Input, S.Failure == Failure {
		self.underlyingSubscriber = subscriber
	}

	@inlinable
	public var combineIdentifier: CombineIdentifier {
		underlyingSubscriber.combineIdentifier
	}

	@inlinable
	public func receive(subscription: Subscription) {
		underlyingSubscriber.receive(subscription: subscription)
	}

	@inlinable
	public func receive(_ input: Input) -> Subscribers.Demand {
		underlyingSubscriber.receive(input)
	}

	@inlinable
	public func receive(completion: Subscribers.Completion<Failure>) {
		underlyingSubscriber.receive(completion: completion)
	}
}

extension Subscriber {
	@inlinable
	public func eraseToAnySubscriber() -> AnySubscriber<Input, Failure> {
		return AnySubscriber(self)
	}
}
#endif
