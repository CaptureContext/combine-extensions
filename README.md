# combine-extensions

[![CI](https://github.com/CaptureContext/combine-extensions/actions/workflows/ci.yml/badge.svg)](https://github.com/CaptureContext/combine-interception/actions/workflows/ci.yml) [![SwiftPM 5.9](https://img.shields.io/badge/swiftpm-5.9-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/Platforms-iOS_13_|_macOS_10.15_|_tvOS_14_|_watchOS_7-ED523F.svg?style=flat) [![@maximkrouk](https://img.shields.io/badge/contact-@capturecontext-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Extensions for Apple Combine framework.

> NOTE: The package is in beta

### TODO

- [x] Proxies

  - [x] DelegateProxy
  - [x] PublishersProxy

  ```swift
  extension PublishersProxy where Base: UISearchBar {
    /// Combine wrapper for `UISearchBarDelegate.searchBarCancelButtonClicked(_:)`
  	public var cancelButtonClicked: some Publisher<Void, Never> {
  		let selector = _makeMethodSelector(
  			selector: #selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:)),
  			signature: base.delegate?.searchBarCancelButtonClicked(_:)
  		)
  		return delegateProxy.proxy_intercept(selector).replaceOutput(with: ())
  	}
  
  	private var delegateProxy: UISearchBarDelegateProxy {
  		.proxy(for: base, \.delegate)
  	}
  }
  
  private class UISearchBarDelegateProxy: 
    DelegateProxy<UISearchBarDelegate>, 
    UISearchBarDelegate 
  {}
  ```

- [x] TypeErasure
  - `NoOptionsScheduler`
  - `AnySubject`
  - `AnySubscriber`

- [x] Selectors interception

  >  See [combine-interception](https://github.com/capturecontext/combine-interception)

- Cancellables
  - [x] NonScopedCancellable

- Operators (_todo: implement using separate Publisher types instead of erasing to AnyPublisher_)
  - [x] SinkOnce
  - [x] SinkEvents
  - [x] SinkValues

- Subjects:
  - [x] PublishSubject

- Subscribers
  - [x] CancelTrackingSubscriber

- Subscriptions
  - [x] CancelTrackingSubscription

- [ ] DemandBuffer

- [ ] Materialize/Dematerialize

- [ ] Relays

- [ ] Look at [CombineExt](https://github.com/CombineCommunity/CombineExt) for more ideas


### Exports

- [combine-interception](https://github.com/capturecontext/combine-interception)
- [combine-schedulers](https://github.com/pointfreeco/combine-schedulers)

## Installation

### Basic

You can add CombineExtensions to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/combine-extensions.git"`](https://github.com/capturecontext/combine-extensions.git) into the package repository URL text field
3. Choose products you need to link them to your project.

### Recommended

If you use SwiftPM for your project, you can add CombineExtensions to your package file.

```swift
.package(
  url: "https://github.com/capturecontext/combine-extensions.git", 
  .upToNextMinor(from: "0.2.0")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "CombineExtensions", 
  package: "combine-extensions"
)
```

```swift
.product(
  name: "CombineExtensionsMacros", 
  package: "combine-extensions"
)
```



## License

This library is released under the MIT license. See [LICENCE](LICENCE) for details.

See [ACKNOWLEDGMENTS][ACKNOWLEDGMENTS] for inspiration references and their licences.

