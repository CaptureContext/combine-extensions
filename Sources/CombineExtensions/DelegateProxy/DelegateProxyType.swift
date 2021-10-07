//
//  DelegateProxyType.swift
//  CombineCocoa
//
//  Created by Joan Disho on 25/09/2019.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if canImport(Combine)
  import Foundation

  private var associatedKey = "delegateProxy"

  public protocol DelegateProxyType {
    associatedtype Object

    func setDelegate(to object: Object)
  }

  public func delegateProxy(
    for object: Any
  ) -> DelegateProxy? {
    objc_getAssociatedObject(object, &associatedKey) as? DelegateProxy
  }

  extension NSObject {
    public var delegateProxy: DelegateProxy? { CombineExtensions.delegateProxy(for: self) }
  }

  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  extension DelegateProxyType where Self: DelegateProxy {
    @discardableResult
    public static func createDelegateProxy(for object: Object) -> Self {
      objc_sync_enter(self)
      defer { objc_sync_exit(self) }

      let delegateProxy: Self

      if let associatedObject = CombineExtensions.delegateProxy(for: object) as? Self {
        delegateProxy = associatedObject
      } else {
        delegateProxy = Self.init()
        objc_setAssociatedObject(
          object,
          &associatedKey,
          delegateProxy,
          .OBJC_ASSOCIATION_RETAIN
        )
      }

      delegateProxy.setDelegate(to: object)

      return delegateProxy
    }
  }
#endif
