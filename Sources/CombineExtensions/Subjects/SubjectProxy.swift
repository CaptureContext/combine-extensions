#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct SubjectProxy<Output, Failure: Error> {
	public init<S: Subject>(_ subject: S) where S.Output == Output, S.Failure == Failure {
		self._sendValue = subject.send
		self._sendSubscription = subject.send(subscription:)
		self._sendCompletion = subject.send(completion:)
	}
	
	let _sendValue: (Output) -> Void
	let _sendSubscription: (Subscription) -> Void
	let _sendCompletion: (Subscribers.Completion<Failure>) -> Void
	
	public func send(_ value: Output) {
		_sendValue(value)
	}
	
	public func send(subscription: Subscription) {
		_sendSubscription(subscription)
	}
	
	public func send(completion: Subscribers.Completion<Failure>) {
		_sendCompletion(completion)
	}
}
#endif
