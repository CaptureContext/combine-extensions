#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Subscriber {
	public func eraseToAnySubscriber() -> AnySubscriber<Input, Failure> {
		return AnySubscriber(self)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnySubscriber<Input, Failure: Error>: Subscriber {
	public init<S: Subscriber>(_ subscriber: S) where S.Input == Input, S.Failure == Failure {
		self.combineIdentifier = subscriber.combineIdentifier
		self._receiveSubscription = subscriber.receive(subscription:)
		self._receiveInput = subscriber.receive
		self._receiveCompletion = subscriber.receive(completion:)
	}
	
	private let _receiveSubscription: (Subscription) -> Void
	private let _receiveInput: (Input) -> Subscribers.Demand
	private let _receiveCompletion: (Subscribers.Completion<Failure>) -> Void
	public let combineIdentifier: CombineIdentifier
	
	public func receive(subscription: Subscription) {
		_receiveSubscription(subscription)
	}
	
	public func receive(_ input: Input) -> Subscribers.Demand {
		_receiveInput(input)
	}
	
	public func receive(completion: Subscribers.Completion<Failure>) {
		_receiveCompletion(completion)
	}
}
#endif
