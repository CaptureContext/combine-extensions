#if canImport(Combine)
import Combine
import Foundation
import CombineSchedulers

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol _PublishSubjectProtocol: Subject {
	func onCancel(perform action: (() -> Void)?)

	init<S: Subject>(_ subject: S) where S.Output == Output, S.Failure == Failure
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public class PublishSubject<Output, Failure: Error>: _PublishSubjectProtocol {
	fileprivate let subject: AnySubject<Output, Failure>

	private var _onCancel: (() -> Void)? = nil
	public func onCancel(perform action: (() -> Void)?) {
		self._onCancel = action
	}

	public required init<S: Subject>(
		_ subject: S
	) where S.Output == Output, S.Failure == Failure {
		self.subject = subject.eraseToAnySubject()
	}

	public convenience init(_ initialValue: Output) {
		self.init(DefaulInnerPublishSubject(initialValue))
	}

	public convenience init() {
		self.init(DefaulInnerPublishSubject())
	}

	public var wrappedValue: AnyPublisher<Output, Failure> {
		subject.eraseToAnyPublisher()
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
final public class OpenPublishSubject<Value, Failure: Error>: PublishSubject<Value, Failure> {
	public override var wrappedValue: AnyPublisher<Value, Failure> {
		get { super.wrappedValue }
	}

	public var projectedValue: SubjectProxy<Value, Failure> { .init(self) }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PublishSubject: Subject {
	final public func send(_ value: Output) {
		subject.send(value)
	}

	final public func send(subscription: Subscription) {
		subject.send(
			subscription: subscription.cancellationTracking { [weak self] in
				self?._onCancel?()
			}
		)
	}

	final public func send(completion: Subscribers.Completion<Failure>) {
		subject.send(completion: completion)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PublishSubject: Publisher {
	public func receive<S>(subscriber: S)
	where Output == S.Input, Failure == S.Failure, S: Subscriber {
		subject.receive(
			subscriber: subscriber.cancellationTracking { [weak self] in
				self?._onCancel?()
			}
		)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private class DefaulInnerPublishSubject<Output, Failure: Error>: Subject {
	let subject: CurrentValueSubject<Output?, Failure>

	init(_ initialValue: Output? = nil) {
		self.subject = .init(initialValue)
	}

	func send(_ value: Output) {
		subject.send(value)
	}

	func send(completion: Subscribers.Completion<Failure>) {
		subject.send(completion: completion)
	}

	func send(subscription: Subscription) {
		subject.send(subscription: subscription)
	}

	func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
		subject.compactMap { $0 }.receive(subscriber: subscriber)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension _PublishSubjectProtocol {
	public init() {
		self.init(DefaulInnerPublishSubject())
	}

	public init<S: Subject>(
		_ subject: S,
		handler: (Self) -> Void
	) where S.Output == Output, S.Failure == Failure {
		self.init(subject)
		handler(self)
	}

	public init(handler: (Self) -> Void) {
		self.init()
		handler(self)
	}
}
#endif
