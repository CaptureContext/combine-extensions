#if canImport(Combine)
import Combine

public typealias PublisherOf<P: Publisher> = Publisher<P.Output, P.Failure>

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

	/// Returns publisher that doesn't emit any values
	///
	/// - Note: Automatically casts Output to the type inferred from the call site
	@inlinable
	public func discardOutput<T>() -> some Publisher<T, Failure> {
		self.flatMap { _ in Empty<T, Failure>() }
	}

	/// Replaces output with constant value
	///
	/// If you have `const(_:)` helper, it's equivalent to
	/// ```swift
	/// publisher.map(const(value))
	/// ```
	///
	/// Consider using `const(_:)` instead
	@inlinable
	public func replaceOutput<T>(with value: T) -> some Publisher<T, Failure> {
		self.map { _ in value }
	}

	/// Resends given events from the publisher to a given subject
	@inlinable
	public func resend<S: Subject>(
		_ events: Subscribers.Sink<Output, Failure>.Event.Set = .all,
		to subject: S
	) -> Cancellable
	where S.Output == Output, S.Failure == Failure {
		sinkEvents { event in
			guard events.containsTag(event.tag) else { return }
			subject.send(event: event)
		}
	}
}
#endif
