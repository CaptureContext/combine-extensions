#if canImport(Combine)
import Combine
import Foundation
import CombineSchedulers

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public typealias NoOptionsSchedulerOf<Scheduler> = CombineSchedulers.AnyScheduler<
	Scheduler.SchedulerTimeType, Never
> where Scheduler: Combine.Scheduler

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Scheduler {
	public func ignoreOptions() -> NoOptionsSchedulerOf<Self> {
		AnyScheduler<SchedulerTimeType, Never>(
			minimumTolerance: { self.minimumTolerance },
			now: { self.now },
			scheduleImmediately: { options, action in
				self.schedule(options: nil, action)
			},
			delayed: { date, tolerance, options, action in
				self.schedule(
					after: date,
					tolerance: tolerance,
					options: nil,
					action
				)
			},
			interval: { date, interval, tolerance, options, action in
				self.schedule(
					after: date,
					interval: interval,
					tolerance: tolerance,
					options: nil,
					action
				)
			}
		)
	}
}
#endif
