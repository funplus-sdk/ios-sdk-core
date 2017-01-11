# Changelog

### v4.1.0

* Update README.

### v4.1.0-alpha.0

* Bugfix #21: Put `LogAgentClient.archive()` to the serial operation queue.
* Bugfix #36: Use different labels for KPI and custom event trackers.
* Performance improvement: Use `autoreleasepool` when serializing JSON strings.
* Refactor: Use `async` blocks instead of `sync` blocks in `LogAgentClient`.
* Refactor: Use a copied data list instead of the original data list when uploading.
* Refactor: Remove `networkReachabilityManager` from `LogAgentClient`, because we're not using it any longer.
* Refactor: Remove `traceHistory` from RUM and Data to avoid potential memory leaks.
* Refactor: Remove `JsonSchema/` from sources.
* Refactor: Stop observing `appDidEnterBackground` and `appWillEnterForeground` in `LogAgentClient`.
* Refactor: Modify `ProgressHandler` to fit code changes.

### v4.0.5-alpha.0

* Bugfix #12. However the fix might not work since the root cause of #12 still remains unclear.

Use this version in caution.

### v4.0.4-alpha.2

* Milliseconds for RUM and Data events.
* Progress callbacks for Data events uploading.
* Modify uploading intervals.
* Remove SDK logs in `FunPlusData.trace()`.

### v4.0.4-alpha.1

* OOM bug fix.

### v4.0.4-alpha.0

- Automatically trace new_user event.
- Bugfix: RUM crashes when too many events coming in.
- Remove logs that are not so useful.

### v4.0.3

* Increase SDK logs uploading interval.
* Set maximum queue size for SDK logs.
* Disable debug queues.

### v4.0.3-alpha.2

* Remove `currencyReceivedType` from payment events.
* Fields correction in payment events.

### v4.0.3-alpha.1

* `FunPlusData.traceCustom(eventName: String, properties: [String: Any])`
* Increase uploading interval.
* Set maximum data queue size.
* Remove call stacks from INFO events.
* Modify logger events format.

### v4.0.3-alpha.0

* `PassportClient` bugfix.
* `PassportClient` test cases.
* API to get current session ID.

### v4.0.2-alpha.0

* Deprecate the `ConfigManager` class.
* Modify fields in Data events.

### v4.0.1-alpha.1

* bugfix: [Missing required module 'CommonCrypto'].

### v4.0.1-alpha.0

* Remove third party frameworks.
* Minor bug fix.
* Typo fix.


