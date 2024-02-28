#if canImport(Combine)
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol PublishersProxyProvider {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PublishersProxyProvider {
	public var publishers: PublishersProxy<Self> { .init(self) }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct PublishersProxy<Base> {
	public let base: Base
	
	public init(_ base: Base) {
		self.base = base
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension NSObject: PublishersProxyProvider {}
#endif
