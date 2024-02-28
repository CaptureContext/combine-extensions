#if canImport(Combine)
import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension DispatchQueue.SchedulerTimeType.Stride {
	public static func interval(_ value: TimeInterval) -> Self {
		.init(floatLiteral: value)
	}
}
#endif
