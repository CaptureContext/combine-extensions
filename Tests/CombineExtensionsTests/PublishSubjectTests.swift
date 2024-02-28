import XCTest
@testable import CombineExtensions

final class PublishSubjectTests: XCTestCase {
	func testCancellation() {
		var cancellables: Set<AnyCancellable> = []
		
		let cancelExpectation = expectation(description: #function)
		let subject = PublishSubject<Int, Never>()
		subject.onCancel(perform: cancelExpectation.fulfill)
		var value = 0
		
		subject
			.sink { value = $0 }
			.store(in: &cancellables)
		
		cancellables.removeAll()
		
		subject.send(1)
		XCTAssertEqual(value, 0)
		waitForExpectations(timeout: 0.1)
	}
	
	func testDefer() {
		var cancellables: Set<AnyCancellable> = []
		let subject = PublishSubject<Int, Never>()
		var actual = 0
		let expected = 1
		func run() -> AnyPublisher<Int, Never> {
			defer { subject.send(expected) }
			return subject.flatMap(CurrentValueSubject.init).eraseToAnyPublisher()
		}
		run()
			.sink { actual = $0 }
			.store(in: &cancellables)
		XCTAssertEqual(actual, expected)
	}
}
