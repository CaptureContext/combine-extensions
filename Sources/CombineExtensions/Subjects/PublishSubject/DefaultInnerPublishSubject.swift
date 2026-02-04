#if canImport(Combine)
import Combine

@usableFromInline
internal class DefaulInnerPublishSubject<Output, Failure: Error>: Subject {
	@usableFromInline
	internal let subject: CurrentValueSubject<Output?, Failure>

	@usableFromInline
	init(_ initialValue: Output? = nil) {
		self.subject = .init(initialValue)
	}

	@usableFromInline
	func send(_ value: Output) {
		subject.send(value)
	}

	@usableFromInline
	func send(completion: Subscribers.Completion<Failure>) {
		subject.send(completion: completion)
	}

	@usableFromInline
	func send(subscription: Subscription) {
		subject.send(subscription: subscription)
	}

	@usableFromInline
	func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
		subject.compactMap { $0 }.receive(subscriber: subscriber)
	}
}
#endif
