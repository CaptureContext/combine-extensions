#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
	@inlinable
	public func sinkResult(_ resultReceiver: @escaping (Result<Output, Failure>) -> Void)
	-> AnyCancellable
	{
		return sink(
			receiveCompletion: { completion in
				guard case let .failure(error) = completion else { return }
				resultReceiver(.failure(error))
			},
			receiveValue: { output in
				resultReceiver(.success(output))
			}
		)
	}

	@inlinable
	public func sinkEvents(
		_ eventsReceiver: @escaping (Subscribers.Sink<Output, Failure>.Event) -> Void
	) -> AnyCancellable {
		return sink(
			receiveCompletion: { completion in
				switch completion {
				case let .failure(error):
					eventsReceiver(.failure(error))
				case .finished:
					eventsReceiver(.finished)
				}
			},
			receiveValue: { output in
				eventsReceiver(.value(output))
			}
		)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output == Never {
	@inlinable
	public func sinkCompletion(
		_ completionReceiver: @escaping (Subscribers.Completion<Failure>) -> Void
	) -> AnyCancellable {
		return sink(
			receiveCompletion: completionReceiver,
			receiveValue: { _ in }
		)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never {
	@inlinable
	public func sinkValues(_ valueReceiver: @escaping (Output) -> Void) -> AnyCancellable {
		return sink(receiveValue: valueReceiver)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Subscribers.Sink {
	public enum Event {
		case value(Input)
		case failure(Failure)
		case finished
	}
}
#endif
