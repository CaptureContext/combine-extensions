#if canImport(Combine)
import Combine
import Foundation

public struct CancellationTrackingSubscription: Subscription {
	public let combineIdentifier: CombineIdentifier = .init()

	@usableFromInline
	internal let subscription: Subscription

	@usableFromInline
	internal let onCancel: () -> Void

	public init(_ subscription: Subscription, onCancel: @escaping () -> Void) {
		self.subscription = subscription
		self.onCancel = onCancel
	}

	@inlinable
	public func request(_ demand: Subscribers.Demand) {
		subscription.request(demand)
	}

	@inlinable
	public func cancel() {
		subscription.cancel()
		onCancel()
	}
}

extension Subscription {
	@inlinable
	public func cancellationTracking(_ action: @escaping () -> Void) -> Subscription {
		return CancellationTrackingSubscription(self, onCancel: action)
	}
}
#endif
