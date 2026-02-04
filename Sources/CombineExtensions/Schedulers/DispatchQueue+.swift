#if canImport(Combine)
import Foundation

extension DispatchQueue.SchedulerTimeType.Stride {
	public static func interval(_ value: TimeInterval) -> Self {
		.init(floatLiteral: value)
	}
}
#endif
