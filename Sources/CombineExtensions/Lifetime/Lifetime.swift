#if canImport(Combine)
import Combine
import Foundation

/// Represents the lifetime of an object, and provides a hook to observe when
/// the object deinitializes.
public final class Lifetime: PublishersProxyProvider {
	fileprivate var cancellables: Set<AnyCancellable> = []
	fileprivate let _invalidationSubject = PassthroughSubject<Never, Never>()
	fileprivate let _hasEndedSubject = CurrentValueSubject<Bool, Never>(false)

	public var hasEnded: Bool { _hasEndedSubject.value  }

	/// Initialize a `Lifetime` from a lifetime token, which is expected to be
	/// associated with an object.
	///
	/// - important: The resulting lifetime object does not retain the lifetime
	///              token.
	///
	/// - parameters:
	///   - token: A lifetime token for detecting the deinitialization of the
	///            associated object.
	public init(_ token: Token?) {
		guard let token else { return  }

		token.isInvalidatedPublisher
			.resend(to: _hasEndedSubject)
			.store(in: &cancellables)

		token.invalidationPublisher
			.resend(to: _invalidationSubject)
			.store(in: &cancellables)
	}
}

extension Lifetime {
	/// Factory method for creating a `Lifetime` and its associated `Token`.
	///
	/// - returns: A `(lifetime, token)` tuple.
	public static func make() -> (lifetime: Lifetime, token: Token) {
		let token = Token()
		return (Lifetime(token), token)
	}

	/// A `Lifetime` that has already ended.
	nonisolated(unsafe) public static let empty = Lifetime(nil)
}

extension Lifetime {
	/// A token object which completes its associated `Lifetime` when
	/// it deinitializes, or when `dispose()` is called.
	///
	/// It is generally used in conjunction with `Lifetime` as a private
	/// deinitialization trigger.
	///
	/// ```
	/// class MyController {
	///		private let (lifetime, token) = Lifetime.make()
	/// }
	/// ```
	public final class Token: Cancellable {
		@PublishSubject<Never, Never>(PassthroughSubject())
		fileprivate var invalidationPublisher

		@PublishSubject<Bool, Never>
		fileprivate var isInvalidatedPublisher

		public init() {
			self._isInvalidatedPublisher = .init(false)
		}

		public func cancel() {
			_isInvalidatedPublisher.send(true)
			_invalidationPublisher.send(completion: .finished)
		}

		deinit {
			cancel()
		}
	}
}

extension Publishers {
	fileprivate struct LifetimeLimitedPublisher<P: Publisher>: Publisher {
		typealias Output = P.Output
		typealias Failure = P.Failure

		let upstream: P
		let lifetime: Lifetime

		func receive<S>(subscriber: S) where S : Subscriber, P.Failure == S.Failure, P.Output == S.Input {
			guard !lifetime.hasEnded else {
				subscriber.receive(completion: .finished)
				return
			}
			
			upstream.receive(subscriber: subscriber)
			lifetime.publishers.invalidation
				.sinkCompletion { _ in subscriber.receive(completion: .finished) }
				.store(in: &lifetime.cancellables)
		}
	}
}

extension Publisher {
	public func limited(to lifetime: Lifetime) -> some PublisherOf<Self> {
		Publishers.LifetimeLimitedPublisher(upstream: self, lifetime: lifetime)
	}
}

extension PublishersProxy where Base == Lifetime {
	public var invalidation: some Publisher<Never, Never> { base._invalidationSubject }
	public var hasEnded: some Publisher<Bool, Never> { base._hasEndedSubject }
}

extension Lifetime {
	@available(*, deprecated, message: "Use `lifetime.publishers.invalidation` instead of `lifetime.publisher`")
	public var publisher: AnyPublisher<Never, Never> {
		_invalidationSubject.eraseToAnyPublisher()
	}

	@available(*, deprecated, message: "Use `lifetime.publishers.hasEnded` instead of `lifetime.hasEndedPublisher`")
	public var hasEndedPublisher: some Publisher<Bool, Never> { _hasEndedSubject }
}
#endif
