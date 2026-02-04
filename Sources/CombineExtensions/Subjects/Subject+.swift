#if canImport(Combine)
import Combine

extension Subject {
	/// Emits 2 events, first one is `output`, second one is `(competion: .finished)`
	@inlinable
	public func send(completion: SubjectValueCompletion<Output>) {
		send(completion.output)
		send(completion: .finished)
	}

	/// Sends `output` or `completion` based on given `Sink.Event`
	public func send(event: Subscribers.Sink<Output, Failure>.Event) {
		switch event {
		case let .value(value): send(value)
		case let .failure(error): send(completion: .failure(error))
		case .finished: send(completion: .finished)
		}
	}
}

public struct SubjectValueCompletion<Output> {
	@usableFromInline
	internal var output: Output

	@usableFromInline
	init(_ output: Output) {
		self.output = output
	}

	@inlinable
	public static func value(_ output: Output) -> SubjectValueCompletion {
		return SubjectValueCompletion(output)
	}
}
#endif
