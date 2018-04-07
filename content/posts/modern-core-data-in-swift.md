---
title: "Modern Core Data in Swift"
description: "An opinionated guide to employing Core Data in a modern Swift app."
date: 2018-03-08T13:18:21+01:00
draft: false
---
Having been released as early as 2005 alongside with _Mac OS X Tiger_, _Core Data_ has come a long way. But despite _Core Data_'s age, _Apple_ has applied serious modernization efforts during the last few years while also adding many new and exciting features.

Due to these modernizations you can now use _Core Data_ with natural and concise _Swift_ syntax. And---using the power of _Swift_ protocols and extensions---one can make working with _Core Data_ even funner!
<!--more-->

> This post is meant to be an update on [Daniel Eggert's awesome post from 2016](https://academy.realm.io/posts/tryswift-daniel-eggert-modern-core-data/) and serve as a reference on basic use-cases.

## Setting Up the Stack
While it is important to know the how to set up _Core Data_ manually, `NSPersistentContainer` is a welcome addition:

{{< highlight swift >}}
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "MyAwesomeModel")
    container.loadPersistentStores { (_, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }

        // Optionally enable automatic merging.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    return container
}()
{{< /highlight >}}

In just a few lines of code, you can load your model (i.e. schema) and store and initialize a store coordinator and view context. A few years ago, this alone would have been enough an entire tutorial!

> Unless you are doing something like a document-based app, you should use one `NSPersistentContainer` per process. If you are interested in sharing a persistent store across multiple processes, e.g. a main app and a today extension, take a look at [Persistent History Tracking in Core Data]({{< relref "/posts/persistent-history-tracking-in-core-data.md" >}}).

## Defining Your Models
Creating _Core Data_ entities in an `.xcdatamodeld` file actually hasn't changed very much. What has changed, though, is defining your model classes in code since _Apple_ finally added code generation for `.xcdatamodeld` files! Having selected an entity, you can see a new property in the _Data Model Inspector_: "Codegen"---with three options to choose from:

1. **Manual/None**: Performs exactly as advertised by doing nothing (old behaviour)
2. **Class Definition**: Generates `NSManagedObject` subclasses per entity in an additional build phase---no additional configuration necessary
3. **Category/Extension**: Similar to the above, but generates _Objective-C_ categories or _Swift_ extensions that add `NSManaged` attribute properties for every entity

And yes, it works for both _Objective-C_ and _Swift_! It also doesn't pollute your workspace as the generated files live in "Derived Data" exclusively. If you would like to know more details, check out [this post in Use Your Loaf](https://useyourloaf.com/blog/core-data-code-generation/).

### There is a Catch
Personally however, I find there are four reasons for sticking with "Manual/None":

1. Either option prevents you from adding documentation to properties/entity attributes that shows up when option-clicking on them.
2. You have no control over access modifiers---it's all public.
3. _Xcode_ might generate to much; do you really need `addToRelationship` and `removeFromRelationship` for every relationship that is also represented by a property?
4. This is the most important one for me: Type safety. By default, _Xcode_ generates untyped `NSSet`s for many-to-one and many-to-many relationships, which is a pity since _Core Data_ supports _Swift_'s `Set<Element>`. Plus, every property---even relationships---will be wrapped `Optional`s, regardless of the optionality chosen in the _Data Model Inspector_.

Even for custom classes, _Xcode_ still synthesizes and initializer that inserts an object into a context and `.fetchRequest()`, which is quite nice.

### Example
Here is an example of how such a custom model class might look:

{{< highlight swift >}}
import CoreData

@objc(User)
final class User: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var givenName: String
    @NSManaged var familyName: String
    @NSManaged var namePrefix: String?
    @NSManaged var nameSuffix: String?
    @NSManaged var organization: Organization
    @NSManaged var authoredCourses: Set<Course>
}
{{< /highlight >}}

Notice the `@objc(User)`? This is needed for the _Objective-C_-Runtime to detect your class. `@NSManaged` is a _Swift_ attribute that tells the compiler that _Core Data_ will handle getting and setting this property, which allows for faulting and other optimizations.

And as you can see, you can use optional and non-optional types from the _Swift Standard Library_ like `String`, `Data`, `Int`, `Double`, `Date`, or `URL` as well as other `NSManagedObject` subclasses and sets thereof.

> If you're like me and would like to use _Swift_'s `Int` be sure to select `Int64` for the corresponding attribute!

## Creating and Deleting Objects
Inserting a new object into an `NSManagedContext` couldn't be easier than using `init(context:)`:

{{< highlight swift >}}
let user = User(context: context)
user.username = "jony"
user.givenName = "Jonathan"
user.familyName = "Ive"
user.organization = apple
{{< /highlight >}}

Deletion, however, has to be invoked on the context:

{{< highlight swift >}}
context.delete(anotherUser)
{{< /highlight >}}

### There is a Small Catch
Suppose you apply database normalization and and end up with a user state that has a one-to-one-relationship with a user. Of course, you could add `user.state = UserState(context:)` for every instantiation. However, this approach tends to be error-prone because its easy to forget or get wrong.

Instead, it would be better to implement custom initialization logic. Unfortunately, you loose synthesized boilerplate when overriding `init(context:)`. This is why I would recommend conforming to a custom protocol such as `CDCreatable`, which basically adds an additional convenience initializer. You can find the code below :)

{{< highlight swift >}}
required convenience init(createIn context: NSManagedObjectContext) {
    self.init(context: context)
    state = UserState(createIn: context)
}
{{< /highlight >}}

After adding this initializer and conforming to `CDCreatable`, `User(createIn:)` automatically creates a state for you. You can also add additional initialization parameters for properties or add more complex logic.

> `init(entity:insertInto:)` will be invoked every time an instance is created, which also happens when fetching from _Core Data_. Custom initialization logic in this method should thus be as lightweight as possible.

As a bonus, `CDCreatable` conformance also synthesizes `delete(in:)` as syntax sugar for `delete()` on `NSManagedObjectContext`.

## Playing Fetch
Just like creating objects, fetching them is pretty straightforward:

1. Create a fetch request using the synthesized static method:
{{< highlight swift >}}
let fetchRequest = User.fetchRequest()
{{< /highlight >}}
2. Customize it to fit your query and use-case:
{{< highlight swift >}}
fetchRequest.predicate = NSPredicate(format: "organization == %@", apple)
fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \User.username, ascending: true)]
{{< /highlight >}}
3. Execute it against a context:
{{< highlight swift >}}
let users = try context.fetch(fetchRequest)
{{< /highlight >}}

Note that---just as with many other _Core Data_ APIs---you can use _Swift_ 4's new `KeyPath`s for constructing `NSSortDescriptor`s! Awesome, right?

> Please use `NSPredicate`s and don't ever fetch everything and then use _Swift_'s `.filter` to narrow down your results. This prevents _Core Data_ from optimizing your query and might result in major performance problems.

### Making it Even Less Verbose
Similar to the one synthesized by _Core Data_, I've added an extension that adds an additional static `NSFetchRequestResult.fetchRequest` that automatically infers the entity name, sets common properties, and returns a typed fetched request.

If you like, you can (optionally) also add convenience properties and methods to your object classes, e.g.:

{{< highlight swift >}}
extension User {
    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \User.username, ascending: true),
    ]
}
{{< /highlight >}}
{{< highlight swift >}}
extension Organization {
    var usersFetchRequest: NSFetchRequest {
        let predicate = NSPredicate(format: "organization == %@", self)
        return User.fetchRequest(predicate: predicate, sortDescriptors: User.defaultSortDescriptors)
    }

    func fetchUsers(in context: NSManagedObjectContext) throws -> [User] {
        return try context.fetch(usersFetchRequest)
    }
}
{{< /highlight >}}

Instead of the above, you can now simply write:

{{< highlight swift >}}
let users = try apple.fetchUsers(in: context)
{{< /highlight >}}

As you can see, I like to separate the fetch requests and actual fetching in order to make working with `NSFetchedResultsController` as easy as fetching.

## Switching Contexts
When you are modifying large amounts of objects or performing a background refresh from a server, you should avoid doing this on the persistent container's `viewContext` as doing so will block the main thread and thus render your application unresponsive. Instead, consider using `performBackgroundTask()`, which creates a new background context that operates on a private background queue.

But it is possible that you might need an object from the view context e.g. to set a relationship with a new object in the private context.

> Doing this will cause your app to crash: Contexts and managed objects should never be used outside their initial queue/context.

Luckily, _Core Data_ manages an opaque `.objectID` for every object. This means you can re-fetch your object in another context in a very performant way and without custom fetch request using `.object(with:)`.

I've written a type-safe utility extension that lets you access every object in another context as simple as `user.in(privateContext)`, which you can also find below.

## Unit Testing
There is not too much to say about unit testing in _Core Data_ other than: Use the in-memory store instead of the default _SQLite_ option if you want to save yourself from unnecessary I/O overhead. Just set `.type` to `NSInMemoryStoreType` on your store description on initialization.

It can also be useful to create convenience constructors for your object classes, which makes creating mock data a little bit more concise. You will also have to consider whether you want to `.reset()` your context in the tests' set-up method or create it from scratch. Keep in mind that the latter option will be more performance-expensive.

## Code
Thanks for reading---I hope you've enjoyed my tips on using _Core Data_ in _Swift_!

Here is the code I've promised :)

{{< gist stoeffn b3626e5fc0cfd039c39f4663fbf53faa >}}
