#if canImport(Combine)
import Foundation

public protocol PublishersProxyProvider {}

extension PublishersProxyProvider {
	public var publishers: PublishersProxy<Self> { .init(self) }
}

public struct PublishersProxy<Base> {
	public let base: Base
	
	public init(_ base: Base) {
		self.base = base
	}
}

extension NSObject: PublishersProxyProvider {}
#endif
