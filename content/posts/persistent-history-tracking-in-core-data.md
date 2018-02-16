---
title: "Persistent History Tracking in Core Data"
description: "A guide to accessing a shared NSPersistentStore across multiple processes."
date: 2018-02-15T19:35:26+01:00
draft: false
---

At _WWDC_ '17, _Apple_ introduced a number of new _Core Data_ features, one of which is _Persistent History Tracking_ or `NSPersistentHistory`. But as of the time of writing, its API is still undocumented. Thus, the only real reference is the [What's New in Core Data](https://developer.apple.com/videos/play/wwdc2017/210/) _WWDC_ session.

Since _Persistent History Tracking_ makes sharing an `NSPersistentStore` across multiple processes and is one of my favorite new _Core Data_ features, it is unfortunate that it mostly seems to fall of the radar.

The purpose of this post is to give a real-world example on how to use it and what makes it so great.
<!--more-->

## The Problem
Let's make it more concrete! My app _StudApp_ has multiple targets: the iOS app (obviously), a file provider extension, and a file provider extension UI. (In the future, it will probably also get a today extension.)

Both the app and the file provider extension enumerate and provide documents from the cloud. How would you implement this functionality? The simplest solution would be to---independently---query the server and immediately present results as requested by the user.

However, it has a huge drawback: User experience. Without caching, the app just feels slow. `URL` caching would be possible but very limited and also doesn't allow for a great offline experience.

### Switching to Core Data

That is why I decided to use _Core Data_ instead. This lovely piece of engineering helped me create rich and performant user interactions.

Then I added my file provider. Suddenly, two sand-boxed processes had to access my database. Doing it sequentially worked just fine. But while the other was running? Bugs. Crashes. Fire.

It was possible for one to invalidate the other's changes or sometimes, data was just completely missing until some "magic reload".

## ...and How to Solve It

Luckily, I remembered [that _WWDC_ session](https://developer.apple.com/videos/play/wwdc2017/210/) I saw. I re-watched and was amazed: Could this solve my syncing problems? The short answer is yes. The long answer is this post.

What _Persistent History Tracking_ basically does is---as the name suggests---tracking changes made to `NSManagedObject`s. Changes are represented by `NSPersistentHistoryTransaction`, which contain some metadata as well as the actual `NSPersistentHistoryChange`s with metadata about the change they represent.

> ###### Why Not Just Tell Core Data to Reload From its Store?
> Well, it works, kinda. You'll probably lose local changes and will most definitely not get notified about object changes, which is crucial for `NSFetchedResultsController` and friends. 

### Merging Changes from History

With _Persistent History Tracking_ you can merge changes from other processes into your `NSManagedObjectContext`. In its simplest form, this process consists of four steps.

1. Enable persistent history tracking by setting a flag when creating your persistent store:
{{< highlight swift >}}
let description: NSPersistentStoreDescription = ... // Your default configuration here
description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

let container = ... // Your default configuration here
container.persistentStoreDescriptions = [description]
{{< /highlight >}}

2. Be sure to save your changes to the persistent store in your first process:
{{< highlight swift >}}
if context.hasChanges {
    try context.save()
}
{{< /highlight >}}

3. Perform an `NSPersistentHistoryChangeRequest` in your second process:
{{< highlight swift >}}
let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: timestamp)

guard
    let historyResult = try context.execute(historyFetchRequest) as? NSPersistentHistoryResult,
    let history = historyResult.result as? [NSPersistentHistoryTransaction]
else {
    fatalError("Cannot convert persistent history fetch result to transactions.")
}
{{< /highlight >}}

4. Merge the transactions' changes returned into your context of choice:
{{< highlight swift >}}
for transaction in history {
    context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
}
{{< /highlight >}}

Changes include a type---either `delete`, `insert`, or `update` and an internal `objectID`. Tombstones are also supported.

And as you might have noticed, you'll either need a date, token, or transaction to create your fetch request. This is important for performance as _Core Data_ will not have to load all history. So you shouldn't just `.fetchHistory(after: .distantPast)` every time.

### Managing Merge States
For every app target you have that accesses your _Core Data_ store, you need to keep track of its merge state, i.e. what is merged and what isn't. Since transaction history is linear, its pretty straightforward: Save the timestamp of the last merged transaction and use and update it when merging and you are ready to go.

> There is an `NSPersistentHistoryToken` that I've tried to persist using `NSKeyedArchiver` but since you can't compare one to another (other than equality) it is pretty difficult to use them for keeping track of your merges. Maybe it will get easier in the future...

And what is the easiest way to do this? Well, you obviously can't use _Core Data_ for this task? `UserDefaults` to the rescue! Just load/save a date keyed by `lastHistoryTransactionTimestamp-<Target>`. Scroll to the bottom to see my implementation :)

### Getting Rid of History
Your changes are merged everywhere. Now what? Well over time, _Persistent History_ will eat quite a lot of disk space. In other words, you'll want to delete history you no longer need.

First, you'll need to determine what is safe to delete. This is entirely up to you but you can take a look at my implementation below.

Then, issue a delete request similar to a fetch request:

{{< highlight swift >}}
let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
try context.execute(deleteHistoryRequest)
{{< /highlight >}}

And that's it—congratulations for implementing _Persistent History Tracking_!

### Tips and Tricks
Before wrapping up, there are a few tips and tricks I'd like to share with you. There first one is so important, I'm gonna frame it:

> Do your merging and deleting inside a `context.performAndWait { … }` block if you want to avoid crashing the entire _Files_ app and yours. I've hunted this bug for quite a while until I saw it in the _WWDC_ demo code…

Now that this is out of the, here is a cool debugging tip: `NSPersistentHistoryTransaction` also provides `author`, `bundleID`, `contextName`, `processID`, and `storeID`---all of which a great for figuring out where a change originated. `author` will be populated from an `NSManagedContext`'s `transactionAuthor`. So let's suppose you have a various background contexts that update specific kinds of data. Just set the transaction author on these context and you will know exactly who is responsible for what change. How cool ist that?

My last tip to use enumerations for your targets---this is a perfect use-case extensible pattern.

### Wrapping Up
Even tough it is lacking documentation, _Persistent History_ is tent pole feature for _Core Data_ that enables its usage across processes without losing your mind. Thank you, _Apple_!

And thank you, dear reader, for baring with me to the end! I hope you enjoyed my first "real" blog post :)

If you did, I would be honored if you gave my website a star on [GitHub](https://github.com/stoeffn/stoeffn)!

As a bonus, you can find a fully working implementation below, which I developed for _StudApp_. Use it as you like!

## My Implementation
To make it work for you, you need to:

1. Update the targets enumeration to reflect your targets
2. Create an app group and shared `UserDefaults`
3. Instantiate `PersistentHistoryService` and call `mergeHistory` and `deleteHistory` when it makes sense in your application flow

<br />

{{< gist stoeffn dafed2b5c671281ab172353749140a46 >}}
