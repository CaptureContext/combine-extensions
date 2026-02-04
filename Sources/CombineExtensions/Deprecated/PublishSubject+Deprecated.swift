#if canImport(Combine)
extension PublishSubject {
	@available(*, deprecated, message: "Use cancellation tracking subscribers instead")
	public func onCancel(perform action: (() -> Void)?) {
		self._onCancel_DEPRECATED = action
	}
}

extension OpenPublishSubject {
	@available(*, deprecated, renamed: "Output")
	public typealias Value = Output
}
#endif
