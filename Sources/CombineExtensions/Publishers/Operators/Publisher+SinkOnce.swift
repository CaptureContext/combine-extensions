#if canImport(Combine)
  import Combine
  import Foundation

  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  private enum DiscardableSinkStorage {
    private static let accessQueue = DispatchQueue(
      label: "DiscardableSinkStorage.accessQueue",
      qos: .default
    )

    static var cancellables: [AnyHashable: Cancellable] = [:]

    static func createCancellationID() -> AnyHashable {
      struct DiscardableSinkCancellationID: Hashable {}
      return DiscardableSinkCancellationID()
    }

    static func store(_ cancellable: Cancellable, for id: AnyHashable) {
      accessQueue.sync {
        cancellables[id] = cancellable
      }
    }

    static func cancel(_ id: AnyHashable) {
      accessQueue.sync {
        cancellables.removeValue(forKey: id)?.cancel()
      }
    }
  }

  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  extension Publisher {
    @discardableResult
    public func sinkOnce(
      onValue: ((Output) -> Void)? = nil,
      onFailure: ((Failure) -> Void)? = nil,
      onFinished: (() -> Void)? = nil
    ) -> Cancellable {
      let cancellationID = DiscardableSinkStorage.createCancellationID()

      let innerCancellable = sinkEvents { event in
        switch event {
        case let .value(value):
          onValue?(value)
        case let .failure(error):
          onFailure?(error)
        case .finished:
          onFinished?()
        }
        DiscardableSinkStorage.cancel(cancellationID)
      }

      DiscardableSinkStorage.store(innerCancellable, for: cancellationID)

      return NonScopedCancellable {
        DiscardableSinkStorage.cancel(cancellationID)
      }
    }
  }

#endif
