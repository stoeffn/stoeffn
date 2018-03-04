---
title: "Reachability in Swift"
description: "Reacting to network reachability changes through a clean API."
date: 2018-03-04T21:10:34+01:00
draft: false
---
In this post, I would like to share my implementation of a simple network reachability service that provides current state and posts notifications when network conditions change---without the need for a third-party library.
<!--more-->

## Usage
To get started, just copy the file below into your project and you are ready to go!

There is an easy-to-access `Reachability.shared` that you should prefer over creating your own instances---doing this for every cell in a table view is not a good idea performance-wise.

When initializing a custom instance, you can also provide a custom `host` to try to connect to. Your application will crash with a fatal error if this host name is invalid.

### Inquiring Network Status

Checking for network connectivity is as easy as:

{{< highlight swift >}}
Reachability.shared.currentFlags.contains(.reachable)
{{< /highlight >}}

Want to know whether the device is on mobile data?

{{< highlight swift >}}
Reachability.shared.currentFlags.contains(.isWWAN)
{{< /highlight >}}

To make sure the reachability flags are up-to-date, call `Reachability.shared.update()`.

### Getting Notified About Changes

First things first: Activate the shared reachability service (e.g. in your `AppDelegate`) so it will start watching for changes.

{{< highlight swift >}}
Reachability.shared.isActive = true
{{< /highlight >}}

Now, it will post an `reachabilityDidChange` notification on every change. It also passes along the new reachability flags.
Plus, _no need to call `update()` anymore!_

Anywhere where you need it, you can observe these notifications on `NotificationCenter.default` as follows:

{{< highlight swift >}}
NotificationCenter.default.addObserver(forName: .reachabilityDidChange, object: nil, queue: .main) { notification in
    print(notification.userInfo?[Notification.Name.reachabilityDidChangeFlagsKey])
}
{{< /highlight >}}

All notifications will be posted on the main queue.

> Don't forget to remove your observer if it is no longer needed!

### How It Works
Basically, this class is just a wrapper around `SCNetworkReachability`, which is a _C_-API contained in `SystemConfiguration`. On initialization, it creates a reachability reference to a network host and determines whether or under what conditions it is reachable.

The change watcher also takes advantage of this API. However, there are some restrictions on callback closures as they need to be compatible with _C_ function pointers. This is why you cannot access `self` inside the closure but instead need to wrap a reference tp it inside an opaque reference, which is then passed along and eventually unwrapped in the callback. After that, the process is really straightforward: Make sure the flags actually changed, update the current flags, and post a notification if needed.

## Code

{{< gist stoeffn 07735ef72c36175a866cb04f7cb20d35 >}}
