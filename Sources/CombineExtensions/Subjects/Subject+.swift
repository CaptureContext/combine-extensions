#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Subject {
	public func send(completion: SubjectValueCompletion<Output>) {
		send(completion.output)
		send(completion: .finished)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct SubjectValueCompletion<Output> {
	fileprivate var output: Output
	
	public static func value(_ output: Output) -> SubjectValueCompletion {
		return SubjectValueCompletion(output: output)
	}
}
#endif
