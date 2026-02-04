#if canImport(Combine)
import Combine
import Foundation
import CombineSchedulers

public protocol _PublishSubjectProtocol: Subject {
	@available(*, deprecated, message: "Use cancellation tracking subscribers instead")
	func onCancel(perform action: (() -> Void)?)

	init<S: Subject>(_ subject: S) where S.Output == Output, S.Failure == Failure
}

@propertyWrapper
public class PublishSubject<Output, Failure: Error>: _PublishSubjectProtocol {
	@usableFromInline
	internal let subject: any Subject<Output, Failure>

	@usableFromInline
	internal var _onCancel_DEPRECATED: (() -> Void)? = nil
	
	public required init<S: Subject>(
		_ subject: S
	) where S.Output == Output, S.Failure == Failure {
		self.subject = subject
	}

	@inlinable
	public convenience init(_ initialValue: Output) {
		self.init(DefaulInnerPublishSubject(initialValue))
	}

	@inlinable
	public convenience init() {
		self.init(DefaulInnerPublishSubject())
	}

	@inlinable
	public var wrappedValue: AnyPublisher<Output, Failure> {
		subject.eraseToAnyPublisher()
	}
}

@propertyWrapper
public final class OpenPublishSubject<Output, Failure: Error>: PublishSubject<Output, Failure> {
	@inlinable
	public override var wrappedValue: AnyPublisher<Output, Failure> {
		get { super.wrappedValue }
	}

	@inlinable
	public var projectedValue: SubjectProxy<Output, Failure> { .init(self) }
}

extension PublishSubject: Subject {
	@inlinable
	final public func send(_ value: Output) {
		subject.send(value)
	}

	@inlinable
	final public func send(subscription: Subscription) {
		subject.send(
			subscription: subscription.cancellationTracking { [weak self] in
				self?._onCancel_DEPRECATED?()
			}
		)
	}

	@inlinable
	final public func send(completion: Subscribers.Completion<Failure>) {
		subject.send(completion: completion)
	}
}

extension PublishSubject: Publisher {
	@inlinable
	public func receive<S>(subscriber: S)
	where Output == S.Input, Failure == S.Failure, S: Subscriber {
		subject.receive(
			subscriber: subscriber.cancellationTracking { [weak self] in
				self?._onCancel_DEPRECATED?()
			}
		)
	}
}

extension _PublishSubjectProtocol {
	@inlinable
	public init() {
		self.init(DefaulInnerPublishSubject())
	}

	@inlinable
	public init<S: Subject>(
		_ subject: S,
		handler: (Self) -> Void
	) where S.Output == Output, S.Failure == Failure {
		self.init(subject)
		handler(self)
	}

	@inlinable
	public init(handler: (Self) -> Void) {
		self.init()
		handler(self)
	}
}
#endif
