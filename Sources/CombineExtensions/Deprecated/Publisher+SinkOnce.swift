#if canImport(Combine)
import Combine
import Foundation
import ConcurrencyExtras

private enum DiscardableSinkStorage {
	private static let accessQueue = DispatchQueue(
		label: "DiscardableSinkStorage.accessQueue",
		qos: .default
	)

	// Synced on accessQueue
	nonisolated(unsafe)
	static var cancellables: [AnyHashable: Cancellable] = [:]

	static func capture(
		_ innerCancellable: (Cancellable) -> Cancellable
	) -> Cancellable {
		struct CancellationID: Hashable {}
		let cancellationID = CancellationID()

		let cancellable = NonScopedCancellable { cancel(cancellationID) }

		store(innerCancellable(cancellable), for: cancellationID)

		return cancellable
	}

	private static func store(_ cancellable: Cancellable, for id: AnyHashable) {
		accessQueue.sync {
			cancellables[id] = cancellable
		}
	}

	private static func cancel(_ id: AnyHashable) {
		accessQueue.sync {
			cancellables.removeValue(forKey: id)?.cancel()
		}
	}
}

extension Publisher {
	@available(*, deprecated, message: "Use `sink` with proper cancellation storage")
	@discardableResult
	public func sinkOnce(
		onValue: ((Output) -> Void)? = nil,
		onFailure: ((Failure) -> Void)? = nil,
		onFinished: (() -> Void)? = nil
	) -> Cancellable {
		DiscardableSinkStorage.capture { cancellable in
			sinkEvents { event in
				switch event {
				case let .value(value):
					onValue?(value)
					cancellable.cancel()
				case let .failure(error):
					onFailure?(error)
				case .finished:
					onFinished?()
				}
			}
		}
	}
}

#endif
