#if canImport(Combine)
import Combine

public typealias PublisherOf<P: Publisher> = Publisher<P.Output, P.Failure>

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
	@inlinable
	public func combinePrevious() -> some Publisher<(prev: Output?, next: Output), Failure> {
		scan(Optional<(Output?, Output)>.none) { ($0?.1, $1) }
			.compactMap { $0 }
	}

	@inlinable
	public func combinePrevious(
		initialValue: Output
	) -> some Publisher<(prev: Output, next: Output), Failure> {
		var previous: Output = initialValue
		return self.map { input in
			let output = (previous, input)
			previous = input
			return output
		}
	}

	@inlinable
	public func eraseError() -> some Publisher<Output, Error> {
		self.mapError { $0 as Error }.eraseToAnyPublisher()
	}

	@inlinable
	public func replaceError(
		with transform: @escaping (Failure) -> Output
	) -> some Publisher<Output, Never> {
		self.catch { Just(transform($0)) }.eraseToAnyPublisher()
	}

	@inlinable
	public func ignoreError() -> some Publisher<Output, Never> {
		self.catch { _ in Empty() }.eraseToAnyPublisher()
	}

	@inlinable
	public func discardOutput<T>() -> some Publisher<T, Failure> {
		self.flatMap { _ in Empty<T, Failure>() }.eraseToAnyPublisher()
	}

	@inlinable
	public func replaceOutput<T>(with value: T) -> some Publisher<T, Failure> {
		self.map { _ in value }.eraseToAnyPublisher()
	}

	@inlinable
	public func resend<S: Subject>(
		to subject: S
	) -> Cancellable
	where S.Output == Output, S.Failure == Failure {
		sink(
			receiveCompletion: subject.send(completion:),
			receiveValue: subject.send(_:)
		)
	}
}
#endif
