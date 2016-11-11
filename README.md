# FunPlus SDK Core

## Requirements

* iOS 8.0+
* Xcode 8.1+
* Swift 3.0+
* The Xcode Terminal Tools (which provide the `xcodebuild` command)

## Example Apps

There are example apps inside the `samples` directory. You can open any of these Xcode projects to see an example of how the FunPlus SDK can be integrated.

## Integration

### Add the SDK to Your Project

1. Add `FunPlusSDK.framework` into your application project.
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
let ENV = SDKEnvironment.sandbox	// sandbox/production

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

### The ID Module

The objective of the ID module is to provide a unified ID for each unique user and consequently make it possible to identify users across all FunPlus services (marketing, payment, etc). Note that the ID module can not be treated as an account module, therefore you cannot use this module to complete common account functionalities such as registration and logging in.

**Get an FPID based on a given user ID**

```swift
FunPlusSDK.getFunPlusID().get(externalID: "{userid}", externalIDType: ExternalIDType.inAppUserID) { res in
    switch (res) {
    case .success(let fpid):
    	// Your logic
    case .failure(let error):
    	// Your logic
    }
}
```

**Bind a new user ID to an existing FPID**

```swift
FunPlusSDK.getFunPlusID().bind(fpid: "{fpid}", externalID: "{userid}", externalIDType: ExternalIDType.inAppUserID) { res in
    switch (res) {
    case .success(let fpid):
    	// Your logic
    case .failure(let error):
    	// Your logic
    }
}
```

### The RUM Module

The RUM module monitors user's actions in real-time and uploads collected data to Log Agent.

**Trace a service_monitoring event**

```swift
FunPlusSDK.getFunPlusRUM().traceServiceMonitoring(...)
```

The `traceServiceMonitoring()` method is defined as below:

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

**Set extra properties to RUM events**

Sometimes you might want to attach extra properties to RUM events. You can set string properties by calling the `setExtraProperty()` method. Note that you can set more than one extra property by calling this method multiple times. Once set, these properties will be stored and attached to every RUM events. You can call the `eraseExtraProperty()` to erase one property.

```swift
FunPlusSDK.getFunPlusRUM().setExtraProperty(key: "{key}", value: "{value}");
FunPlusSDK.getFunPlusRUM().eraseExtraProperty(key: "{key}");
```

### The Data Module

The Data module traces client events and uploads them to FunPlus BI System.

The SDK traces following KPI events automatically:

- session_start
- session_end
- new_user
- payment

**Trace custom events**

```swift
FunPlusSDK.getFunPlusData().traceCustom(event)
```

Besides those four KPI events, you might want to trace some custom events. Call the `traceCustom()` method to achieve this task.

The event you're passing in to this method is a dictionary. Below is an example:

```json
{
    "app_id": "{YourAppId}",
    "data_version": "2.0",
    "event": "level_up",
    "user_id": "{UserId}",
    "session_id": "{SessionId}",
    "ts": "{Timestamp(millisecond)}",
    "properties": {
        "app_version": "{YourAppId}",
        "os": "{android or ios}",
        "os_version": "{OsVersion}",
        "device": "{DeviceName}",
        "lang": "{LanguageCode, for example: 'en'}",
        "install_ts": "{Timestamp(millisecond)}",
        // Other custom properties.
    }
```

**Set extra properties to Data events**

```java
FunPlusSDK.getFunPlusData().setExtraProperty(key: "{key}", value: "{value}");
FunPlusSDK.getFunPlusData().eraseExtraProperty(key: "{key}");
```

## FAQ

**Q: Why the hell is the parameter list of  `TraceServiceMonitoring()` so long?**

A: Please consult RUM team on that :)