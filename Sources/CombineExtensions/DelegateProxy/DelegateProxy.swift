//
//  DelegateProxy.swift
//  CombineCocoa
//
//  Created by Joan Disho on 25/09/2019.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Foundation
import CombineInterception
import _InterceptionUtils

open class AnyDelegateProxy: NSObject {
	public weak var _forwardee: NSObjectProtocol? {
		didSet { originalSetter(self) }
	}

	private(set) public var interceptedSelectors: Set<Selector> = []

	private let lifetime: Lifetime
	private let originalSetter: (AnyObject) -> Void

	public required init(lifetime: Lifetime, _ originalSetter: @escaping (AnyObject) -> Void) {
		self.lifetime = lifetime
		self.originalSetter = originalSetter
	}

	public override func forwardingTarget(for selector: Selector!) -> Any? {
		return interceptedSelectors.contains(selector) ? nil : _forwardee
	}

	public func proxy_intercept(_ selector: Selector) -> some Publisher<InterceptionResult<Any, Any>, Never> {
		interceptedSelectors.insert(selector)
		originalSetter(self)
		return intercept(selector).limited(to: lifetime)
	}

	public func proxy_intercept<Args, Output>(
		_ selector: _MethodSelector<Args, Output>
	) -> some Publisher<InterceptionResult<Args, Output>, Never> {
		interceptedSelectors.insert(selector.wrappedValue)
		originalSetter(self)
		return intercept(selector).limited(to: lifetime)
	}

	public override func responds(to selector: Selector!) -> Bool {
		if interceptedSelectors.contains(selector) { return true }
		return (_forwardee?.responds(to: selector) ?? false) || super.responds(to: selector)
	}
}

private let hasSwizzledKey = AssociationKey<Bool>(default: false)

extension AnyDelegateProxy {
	// FIXME: This is a workaround to a compiler issue, where any use of `Self`
	//        through a protocol would result in the following error messages:
	//        1. PHI node operands are not the same type as the result!
	//        2. LLVM ERROR: Broken function found, compilation aborted!
	public static func proxy<Delegate: NSObjectProtocol>(
		for instance: NSObject,
		protocol: Delegate.Type,
		setter: Selector,
		getter: Selector
	) -> AnyDelegateProxy {
		return _proxy(
			for: instance,
			protocol: `protocol`,
			setter: setter,
			getter: getter
		)
	}

	private static func _proxy<Delegate: NSObjectProtocol>(
		for instance: NSObject,
		protocol: Delegate.Type,
		setter: Selector,
		getter: Selector
	) -> AnyDelegateProxy {
		return synchronized(instance) {
			let key = AssociationKey<AnyDelegateProxy?>(setter.delegateProxyAlias)

			if let proxy = instance.associations.value(forKey: key) {
				return proxy
			}

			let superclass: AnyClass = class_getSuperclass(swizzleClass(instance))!

			let invokeSuperSetter: @convention(c) (NSObject, AnyClass, Selector, AnyObject?) -> Void = { object, superclass, selector, delegate in
				typealias Setter = @convention(c) (NSObject, Selector, AnyObject?) -> Void
				let impl = class_getMethodImplementation(superclass, selector)
				unsafeBitCast(impl, to: Setter.self)(object, selector, delegate)
			}

			let newSetterImpl: @convention(block) (NSObject, AnyObject?) -> Void = { object, delegate in
				if let proxy = object.associations.value(forKey: key) {
					proxy._forwardee = (delegate as! Delegate?)
				} else {
					invokeSuperSetter(object, superclass, setter, delegate)
				}
			}

			// Hide the original setter, and redirect subsequent delegate assignment
			// to the proxy.
			instance.swizzle((setter, newSetterImpl), key: hasSwizzledKey)

			// As Objective-C classes may cache the information of their delegate at
			// the time the delegates are set, the information has to be "flushed"
			// whenever the proxy _forwardee is replaced or a selector is intercepted.
			let proxy = self.init(lifetime: instance.publishers.lifetime) { [weak instance] proxy in
				guard let instance = instance else { return }
				invokeSuperSetter(instance, superclass, setter, proxy)
			}

			typealias Getter = @convention(c) (NSObject, Selector) -> AnyObject?
			let getterImpl: IMP = class_getMethodImplementation(object_getClass(instance), getter)!
			let original = unsafeBitCast(getterImpl, to: Getter.self)(instance, getter) as! Delegate?

			// `proxy._forwardee` would invoke the original setter regardless of
			// `original` being `nil` or not.
			proxy._forwardee = original

			// The proxy must be associated after it is set as the target, since
			// `base` may be an isa-swizzled instance that is using the injected
			// setters above.
			instance.associations.setValue(proxy, forKey: key)

			return proxy
		}
	}
}

extension AnyDelegateProxy {
	public static func proxy<
		Instance: NSObject,
		Delegate: NSObjectProtocol
	>(
		for instance: Instance,
		_ delegateKeyPath: WritableKeyPath<Instance, Delegate?>
	) -> Self {
		let selector = _unsafeMakePropertySelector(delegateKeyPath)
		return proxy(
			for: instance,
			protocol: Delegate.self,
			setter: selector.setter,
			getter: selector.getter
		) as! Self
	}
}

protocol DelegateProxyType<Delegate>: AnyDelegateProxy {
	associatedtype Delegate: NSObjectProtocol
	var asDelegate: Delegate { get }
	var forwardee: Delegate? { get set }
}

extension DelegateProxyType {
	public var asDelegate: Delegate { self as! Delegate }

	public var forwardee: Delegate? {
		get { _forwardee as? Delegate }
		set { _forwardee = newValue }
	}
}

open class DelegateProxy<Delegate: NSObjectProtocol>: AnyDelegateProxy, DelegateProxyType {}
#endif
