#if canImport(Combine)
import Combine

extension Subscribers.Sink {
	public enum Event {
		case value(Input)
		case failure(Failure)
		case finished

		public var tag: Tag {
			switch self {
			case .value: .value
			case .failure: .failure
			case .finished: .finished
			}
		}

		public enum Tag: Hashable {
			case value
			case failure
			case finished
		}

		public struct Set: OptionSet, Hashable {
			public let rawValue: Int

			public init(rawValue: Int) {
				self.rawValue = rawValue
			}

			public static var value: Self { .init(rawValue: 1 << 0) }
			public static var failure: Self { .init(rawValue: 1 << 1) }
			public static var finished: Self { .init(rawValue: 1 << 2) }
			public static var all: Self { [.value, .failure, .finished] }
			public static var completion: Self { [.failure, .finished] }

			public func containsTag(_ tag: Event.Tag) -> Bool {
				switch tag {
				case .value: contains(.value)
				case .failure: contains(.failure)
				case .finished: contains(.finished)
				}
			}
		}
	}
}

extension Publisher {
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

	@inlinable
	public func sinkResult(
		_ resultReceiver: @escaping (Result<Output, Failure>) -> Void
	) -> AnyCancellable {
		return sinkEvents { event in
			switch event {
			case let .value(value): resultReceiver(.success(value))
			case let .failure(error): resultReceiver(.failure(error))
			default: return
			}
		}
	}

	@inlinable
	public func sinkCompletion(
		_ completionReceiver: @escaping (Subscribers.Completion<Failure>) -> Void
	) -> AnyCancellable {
		return sinkEvents { event in
			switch event {
			case .finished: completionReceiver(.finished)
			case let .failure(error): completionReceiver(.failure(error))
			default: return
			}
		}
	}
}

extension Publisher where Failure == Never {
	@inlinable
	public func sinkValues(_ valueReceiver: @escaping (Output) -> Void) -> AnyCancellable {
		return sink(receiveValue: valueReceiver)
	}
}
#endif
