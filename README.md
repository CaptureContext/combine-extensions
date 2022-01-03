# combine-extensions

[![SwiftPM 5.3](https://img.shields.io/badge/swiftpm-5.3-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/Platforms-iOS_13_|_macOS_10.15_|_tvOS_14_|_watchOS_7-ED523F.svg?style=flat) [![@maximkrouk](https://img.shields.io/badge/contact-@capturecontext-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Extensions for Apple Combine framework.

> NOTE: The package is early beta

### TODO

- [x] DelegateProxy
- [x] PublishersProxy
- [x] TypeErasure
  - NoOptionsScheduler
  - AnySubject
  - AnySubscriber
- [x] Selectors interception
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
  name: "combine-extensions",
  url: "https://github.com/capturecontext/combine-extensions.git", 
  .upToNextMinor(from: "0.0.3")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "CombineExtensions", 
  package: "combine-extensions"
)
```

