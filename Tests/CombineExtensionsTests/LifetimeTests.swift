import Testing
import Foundation
import ConcurrencyExtras
@testable import CombineExtensions

@Suite("LifetimeTests")
struct LifetimeTests {
	class Object: NSObject {}

	@Test
	@available(watchOS 9.0, tvOS 16.0, *)
	func test() async throws {
		var object: Object! = Object()

		let receivedInvalidated: LockIsolated<[Void]> = .init([])
		let receivedEnded: LockIsolated<[Bool]> = .init([])

		let pub1 = object.lifetime.publishers.invalidation.uncheckedSendable()
		let invalidationTask = Task {
			try await pub1.completion()
			receivedInvalidated.withValue { $0.append(()) }
		}

		let pub2 = object.lifetime.publishers.hasEnded.uncheckedSendable()
		let hasEndedEventsTask = Task {
			for await hasEnded in pub2.values {
				receivedEnded.withValue { $0.append(hasEnded) }
			}
		}

		await Task.yield()

		// yeild is not enough for some reason
		try await Task.sleep(for: .milliseconds(100))

		#expect(receivedInvalidated.count == 0)
		#expect(receivedEnded.value == [false])

		object = nil
		
		await Task.yield()

		// [sometimes] yeild is not enough for some reason
		try await Task.sleep(for: .milliseconds(100))

		#expect(receivedInvalidated.count == 1)
		#expect(receivedEnded.value == [false, true])

		await Task.yield()

		// ensure everything is completed since
		// yield wasnt enough in prev 2 cases
		try await Task.sleep(for: .milliseconds(100))

		invalidationTask.cancel()
		hasEndedEventsTask.cancel()
	}
}
