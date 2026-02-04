import Testing
@testable import CombineExtensions

@Suite("NonScopedCancellableTests")
struct NonScopedCancellableTests {
	@Test
	func cancelsOnCancel() async throws {
		var isCancelled: Bool = false
		let cancellable = NonScopedCancellable {
			isCancelled = true
		}

		cancellable.cancel()
		#expect(isCancelled == true)
	}

	@Test
	func noCancellationOnDeinit() async throws {
		do { // AnyCancellable cancels on deinit
			var isCancelled: Bool = false
			var cancellable: AnyCancellable? = AnyCancellable {
				isCancelled = true
			}

			cancellable = nil
			#expect(cancellable == nil) // silences a warning
			#expect(isCancelled == true)
		}

		do { // NonScopedCancellable is not cancelled on deinit
			var isCancelled: Bool = false
			var cancellable: NonScopedCancellable? = NonScopedCancellable {
				isCancelled = true
			}

			cancellable = nil
			#expect(cancellable == nil) // silences a warning
			#expect(isCancelled == false)
		}

		do { // AnyCancellable cancels on deinit even when wrapped into NonScopedCancellable
			var isCancelled: Bool = false
			var cancellable: NonScopedCancellable? = NonScopedCancellable(AnyCancellable {
				isCancelled = true
			})

			cancellable = nil
			#expect(cancellable == nil) // silences a warning
			#expect(isCancelled == true)
		}
	}
}
