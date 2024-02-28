#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Subject {
	public func eraseToAnySubject() -> AnySubject<Output, Failure> {
		return AnySubject(self)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class AnySubject<Output, Failure: Error>: Subject {
	public init<S: Subject>(_ subject: S) where S.Output == Output, S.Failure == Failure {
		self._sendValue = subject.send
		self._sendSubscription = subject.send(subscription:)
		self._sendCompletion = subject.send(completion:)
		self._receiveSubscriber = subject.receive(subscriber:)
	}
	
	let _sendValue: (Output) -> Void
	let _sendSubscription: (Subscription) -> Void
	let _sendCompletion: (Subscribers.Completion<Failure>) -> Void
	let _receiveSubscriber: (AnySubscriber<Output, Failure>) -> Void
	
	public func send(_ value: Output) {
		_sendValue(value)
	}
	
	public func send(subscription: Subscription) {
		_sendSubscription(subscription)
	}
	
	public func send(completion: Subscribers.Completion<Failure>) {
		_sendCompletion(completion)
	}
	
	public func receive<S>(subscriber: S)
	where S: Subscriber, Failure == S.Failure, Output == S.Input {
		_receiveSubscriber(subscriber.eraseToAnySubscriber())
	}
}
#endif
