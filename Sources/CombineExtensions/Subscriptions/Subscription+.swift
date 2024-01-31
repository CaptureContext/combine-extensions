#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Subscription {
	public func cancellationTracking(_ action: @escaping () -> Void) -> Subscription {
		return CancelTrackingSubscription(self, onCancel: action)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct CancelTrackingSubscription: Subscription {
	init(_ subscription: Subscription, onCancel: @escaping () -> Void) {
		self.subscription = subscription
		self.onCancel = onCancel
	}

	let subscription: Subscription
	let onCancel: () -> Void

	let combineIdentifier: CombineIdentifier = .init()

	func request(_ demand: Subscribers.Demand) {
		subscription.request(demand)
	}
	
	func cancel() {
		subscription.cancel()
		onCancel()
	}
}
#endif
