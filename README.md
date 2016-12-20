# FunPlus SDK Core

## Requirements

* iOS 9.0+
* Xcode 8.1+
* Swift 3.0+
* The Xcode Terminal Tools (which provide the `xcodebuild` command)

## Table of  Contents

* [Integration](#integration)
  * [Add the SDK to Your Project](#add-the-sdk-to-your-project)
  * [Install the SDK](#install-the-sdk)
* [Usage](#usage)
  * [The ID Module](#the-id-module)
    - [Get an FPID Based on a Given User ID](get-an-fpid-based-on-a-given-user-id)
    - [Bind a New User ID to an Existing FPID](#bind-a-new-user-id-to-an-existing-fpid)
  * [The RUM Module](#the-rum-module)
    - [Trace a Service Monitoring Event](#trace-a-service-monitoring-event)
    - [Set Extra Properties to RUM Events](#set-extra-properties-to-rum-events)
  * [The Data Module](#the-data-module)
    - [Trace Custom Events](#trace-custom-events)
    - [Set Extra Properties to Data Events](#set-extra-properties-to-data-events)
* [FAQ](#faq)

## Integration

### Add the SDK to Your Project

1. Add `FunPlusSDK.framework` into your application project.
2. Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
3. In the tab bar at the top of that window, open the "General" panel.
4. Click on the `+` button under the "Embedded Binaries" section.
5. Select the four previously added frameworks into this section.
6. And that's it.

### Install the SDK

Put the following initialization codes in your project. Usually the `application:didFinishLaunchingWithOptions` delegate method is a good place to put the codes in.

```swift
import FunPlusSDK

let APP_ID = "{YourAppId}"
let APP_KEY = "{YourAppKey}"
let RUM_TAG = "{YourRumTag}"
let RUM_KEY = "{YourRumKey}"
let ENV = SDKEnvironment.sandbox	// sandbox/production

FunPlusSDK.install(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: ENV)
```

Now you've done initializing the SDK.

### Config the SDK

You may want to override SDK's default config values. In such a case, you need to initialize the SDK in a different way, as the following code snippet illustrates.

```swift
import FunPlusSDK

let APP_ID = "{YourAppId}"
let APP_KEY = "{YourAppKey}"
let RUM_TAG = "{YourRumTag}"
let RUM_KEY = "{YourRumKey}"
let ENV = SDKEnvironment.sandbox	// sandbox/production

let funPlusConfig = FunPlusConfig(appId: APP_ID, appKey: APP_KEY, rumTag: RUM_TAG, rumKey: RUM_KEY, environment: ENV)

funPlusConfig.setRumUploadInterval(10)
             .setAutoSessionStartAndEnd(false)
             .end()

FunPlusSDK.install(funPlusConfig: funPlusConfig)
```

Here's all the config values that can be overrided.

| name                   | type     | description                              |
| ---------------------- | -------- | ---------------------------------------- |
| rumUploadInterval      | Int64    | This value indicates a time interval to trigger a RUM events uploading process. Default is 30. |
| rumSampleRate          | Double   | This value indicates percentage of RUM events to be traced for sampling. Default is 1.0. |
| rumEventWhitelist      | [String] | RUM events in this array will always be traced. Default is an empty array. |
| rumUserWhitelist       | [String] | RUM events produced by users in this array will always be traced. Default is an empty array. |
| rumUserBlacklist       | [String] | RUM events produced by users in this array will never be traced. `rumUesrWhitelist` will be checked before this array. Default is an empty array. |
| dataUploadInterval     | Int64    | This value indicates a time interval to trigger a Data events uploading process. Default is 30. |
| autoSessionStartAndEnd | Bool     | If set true, SDK will automatically trigger session starting and session ending. Default is true. |

## Usage

### The ID Module

The objective of the ID module is to provide a unified ID for each unique user and consequently make it possible to identify users across all FunPlus services (marketing, payment, etc). Note that the ID module can not be treated as an account module, therefore you cannot use this module to complete common account functionalities such as registration and logging in.

#### Get an FPID based on a given user ID

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

#### Bind a new user ID to an existing FPID

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

#### Trace a Service Monitoring Event

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

#### Set Extra Properties to RUM Events

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

#### Trace custom events

```swift
FunPlusSDK.getFunPlusData().traceCustom(event:)
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
        "other_properties": "..."
    }
```

It's not fun to type all common fields again and again. Instead, you are allowed to pass in only event-specific fields by picking an alternative method:

```swift
FunPlusSDK.getFunPlusData().traceCustom(eventName:, properties:)
```

#### Set extra properties to Data events

```java
FunPlusSDK.getFunPlusData().setExtraProperty(key: "{key}", value: "{value}");
FunPlusSDK.getFunPlusData().eraseExtraProperty(key: "{key}");
```

## FAQ

**Q: Why the hell is the parameter list of  `TraceServiceMonitoring()` so long?**

A: Please consult RUM team on that :)

**Q: What is `bindFPID()` for and when should I use it?**

A: In most cases you are not gonna use this method. For cases that one player binds his/her game account to different social accounts, you need to call this method.

Below is an example:

```swift
let fpid = FunPlusSDK.getFunPlusID().getFPID("testuser@funplus.com", ExternalIDType.email, ...);

// When player binds his/her account with Facebook.
FunPlusSDK.getFunPlusID().bindFPID(fpid, "fb1234", ExternalIDType.facebookID, ...);
```

