# FunPlus SDK

## Requirements

* iOS 8.0+
* Xcode 8.1+
* Swift 3.0+
* The Xcode Terminal Tools (which provide the `xcodebuild` command)

## Example Apps

There are example apps inside the `samples` directory. You can open any of these Xcode projects to see an example of how the FunPlus SDK can be integrated.

## Integration

### Add the SDK to Your Project

1. Add `FunPlusSDK.framework` and `funsdk-default-config.plist` into your application project.
2. Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
3. In the tab bar at the top of that window, open the "General" panel.
4. Click on the `+` button under the "Embedded Binaries" section.
5. Select the four previously added frameworks into this section.
6. And that's it.

### Install the SDK

Modify your `AppDelegate.swift` file as below code snippet demonstrates.

```swift
import FunPlusSDK

let APP_ID = "test"
let APP_KEY = "funplus"
let ENV = SDKEnvironment.sandbox

func application(_ application: UIApplication, didFinishLaunchingWithOptions
	launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	do {
        try FunPlusSDK.install(appId: APP_ID, appKey: APP_KEY, environment: ENV)
    } catch {
        // Something is wrong?!!
    }
}
```



## Usage

To trace a service_monitoring event.

```swift
FunPlusSDK.getFunPlusRUM().traceServiceMonitoring(...)
```

Below is the signature of the `traceServiceMonitoring` method.

```swift
/**
    - parameter serviceName:	Name of the service.
    - parameter httpUrl:		Requesting URL of the service.
    - parameter httpStatus:		The response status (can be string).
    - parameter requestSize:	Size of the request body.
    - parameter responseSize:	Size of the response body.
    - parameter httpLatency:	The request duration (in milliseconds).
    - parameter requestTs:		Requesting timestamp.
    - parameter responseTs:		Responding timestamp.
    - parameter requestId:		Identifier of current request.
    - parameter targetUserId:	User ID.
    - parameter gameServerId:	Game server ID.
 */
public func traceServiceMonitoring(
    serviceName: String,
    httpUrl: String,
    httpStatus: String,
    requestSize: Int,
    responseSize: Int,
    httpLatency: Int64,
    requestTs: Int64,
    responseTs: Int64,
    requestId: String,
    targetUserId: String,
    gameServerId: String
)
```

## FAQs
