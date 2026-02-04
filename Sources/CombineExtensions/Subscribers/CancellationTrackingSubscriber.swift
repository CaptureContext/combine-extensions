#if canImport(Combine)
import Combine
import Foundation

@available(*, deprecated, renamed: "CancellationTrackingSubscriber")
public typealias CancelTrackingSubscriber = CancellationTrackingSubscriber

public struct CancellationTrackingSubscriber<InnerSubscriber: Subscriber>: Subscriber {
	@usableFromInline
	internal let subscriber: InnerSubscriber

	@usableFromInline
	internal let onCancel: () -> Void

	public init(
		_ subscriber: InnerSubscriber,
		onCancel: @escaping () -> Void
	) {
		self.subscriber = subscriber
		self.onCancel = onCancel
	}

	@inlinable
	public var combineIdentifier: CombineIdentifier {
		subscriber.combineIdentifier
	}

	@inlinable
	public func receive(subscription: Subscription) {
		subscriber.receive(subscription: subscription.cancellationTracking(onCancel))
	}

	@inlinable
	public func receive(_ input: InnerSubscriber.Input) -> Subscribers.Demand {
		subscriber.receive(input)
	}

	@inlinable
	public func receive(completion: Subscribers.Completion<InnerSubscriber.Failure>) {
		subscriber.receive(completion: completion)
	}
}

extension Subscriber {
	@inlinable
	public func cancellationTracking(
		_ action: @escaping () -> Void
	) -> CancellationTrackingSubscriber<Self> {
		return CancellationTrackingSubscriber(self, onCancel: action)
	}
}
#endif
