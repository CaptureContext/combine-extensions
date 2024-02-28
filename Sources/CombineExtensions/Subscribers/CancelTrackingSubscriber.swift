#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Subscriber {
	public func cancellationTracking(
		_ action: @escaping () -> Void
	) -> CancelTrackingSubscriber<Self> {
		return CancelTrackingSubscriber(self, onCancel: action)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct CancelTrackingSubscriber<InnerSubscriber: Subscriber>: Subscriber {
	public init(
		_ subscriber: InnerSubscriber,
		onCancel: @escaping () -> Void
	) {
		self.subscriber = subscriber
		self.onCancel = onCancel
	}
	
	private let subscriber: InnerSubscriber
	private let onCancel: () -> Void
	
	public var combineIdentifier: CombineIdentifier {
		subscriber.combineIdentifier
	}
	
	public func receive(subscription: Subscription) {
		subscriber.receive(subscription: subscription.cancellationTracking(onCancel))
	}
	
	public func receive(_ input: InnerSubscriber.Input) -> Subscribers.Demand {
		subscriber.receive(input)
	}
	
	public func receive(completion: Subscribers.Completion<InnerSubscriber.Failure>) {
		subscriber.receive(completion: completion)
	}
}
#endif
