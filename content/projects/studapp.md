---
title: "StudApp"
description: "Stud.IP to Go"
date: 2018-04-07T14:41:17+02:00
draft: false
---

StudApp is an _iOS_ application for the [Stud.IP learning platform](http://www.studip.de), which is used by more than half a million students and lecturers at over 40 _German_ universities and 30 other organizations like the _German Football Association_ or a state police. 

This project aims to take this platform to the next level by leveraging native capabilities of _iOS_. With _StudApp_, it easier than ever to browse your courses, documents, and announcements! Being officially certified by _Stud.IP e.V._, it provides excellent ways to stay up-to-date.

And—just like _Stud.IP_ itself—_StudApp_ is completely open source and free to be used by anyone as an no-cost app on the _App Store_.
<!--more-->

<a href="https://itunes.apple.com/us/app/studapp/id1317593772?mt=8" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/assets/shared/badges/en-us/appstore-lrg.svg) no-repeat;width:135px;height:40px;background-size:contain;"></a>
<iframe allowtransparency="true" scrolling="no" frameborder="0" src="https://buttons.github.io/buttons.html#href=https%3A%2F%2Fgithub.com%2Fstoeffn%2FStudApp&data-text=Star&data-icon=octicon-star&data-size=large&data-show-count=true&aria-label=Star%20stoeffn%2Fstoeffn%20on%20GitHub" style="width: 64px; height: 28px; border: none;"></iframe>

If you know _German_ check out the [official StudApp website](https://studapp.stoeffn.de/)!

{{< figure src="https://github.com/stoeffn/StudApp/raw/master/Screenshots/iPhone-X-Courses.png" title="Screenshot: Course Overview" alt="Screenshot of StudApp" height="640" class="unframed">}}

## Motivation

Being a student at a university that employs _Stud.IP_, it has always bugged me how complicated it has been to learn with your professors' slides on _iPhone_ and _iPad_: You either had to use the mobile site: sign in, find the document you are looking for, and download. Or—to access your files when offline—download every single one onto your computer and then sync them with _iCloud Drive_. As you might imagine, both options are quite tedious.

This is why I started development of _Stud.App_ pretty much a few weeks after starting university together with _Julian Lobe_, who I got know in a math course. _Stud.App_ served as a document downloader for _Stud.IP_. We later added support for messaging and schedules.

## Progression

Due to time constraints, unfortunately, we realized that we had to pause this project.

But half a year later—inspired by _iOS 11_'s new _Files_ app, which completely changed file providers for good—I thought I'd give it another shot: I started _Stud.Sync_ as a very minimal app with a _Stud.IP_ file provider. Because file providers are implemented as app extensions, _StudKit_ was born: A cross-platform _Swift_ wrapper for _Stud.IP_'s APIs. It also takes care of persisting and organizing data using _Core Data_. I couldn't reuse much of _Stud.App_ because _Stud.IP 4_ features significant API changes.

As _Stud.Sync_ grew I came to the conclusion that it would be cool to share this handy tool with my fellow students and lecturers. Since it started to become more than just a file provider, I rebranded it as _StudApp_.

## Making It to the App Store

After many months of coding and continuous feedback from _Julian_, the time had come when I thought it was ready for release!

I turned to _Cornelis Kater_, chairperson of _Stud.IP e.V._, which is a public interest society dedicated accelerating _Stud.IP_ development and external representation. Luckily, he was immediately excited about _Stud.IP_ getting an _iOS_ app and kindly offered all kinds of help!

Following that, I came to know the development community behind _Stud.IP_, who help me by fixing API bugs and even programming new API routes for me! Notably, _Rasmus Fuhse_ always supports me with feedback, ideas, and API assistance.

Having followed necessary guidelines and presented _StudApp_ at the _Stud.IP Developer Conference 2018_ in _Bremen_, my app is now officially certified and, thus, ready for release!

## Features

Having told you all about how it came to be, I'd like to finally introduce you to _StudApp_'s features. As this is a developer blog, I'm also going to illustrate some technical background.

Please note that _StudApp_ requires _iOS 10_ or higher and _Stud.IP 4_ or newer. However, a few feature—most notably the file provider but also little things like table cell swiping—need a more recent system version. Similarly, some APIs are unavailable on prior _Stud.IP_ releases.

### Dynamic Organizations

First of all, _StudApp_ isn't bound to one university: It is designed to be compatible with any _Stud.IP_!

When signing in, users can select their organization and authenticate against it. This organization picker is backed by _CloudKit_, which makes it pretty easy to add and remove organizations without the need for an app update.

_StudApp_ automatically adapts to the chosen organization by adapting the the tint color and disabling features that are unavailable.

### Offline Availability

Using _Core Data_, I'm able to achieve full offline availability while retaining great performance throughout the app.

I've built an efficient mechanism that automatically updates stale data and removes deleted records locally. It respects whether the user is in "Low Power Mode" and doesn't repeatedly update the same data in a short amount of time in order to save mobile data. By bundling requests, _StudApp_ also tries to preserve battery life.

Of course, you can also download documents. Learn more about that in _File Management_.

### Courses

Users can select their semesters of interest. These semesters are then available in the main view and can be expanded or collapsed, making navigation a breeze. Courses that span multiple semesters correctly appear in all of them. And if a certain course isn't relevant, you can easily hide it away.

With just a swipe, one can change a course's color and affect how they are sorted. This is pretty useful if you want to keep similar courses together and automatically synchronized with the website.

> This feature requires _Stud.IP 4.2_ or the [CourseGroupPatchRoute plugin](https://develop.studip.de/studip/plugins.php/pluginmarket/presenting/details/ea38bb4d09d55b86f740c4152d5b3ac7).

Apart from announcements and documents, course details views provide additional details, e.g. lecturers, locations, the next event, and description with data detection and easy copying. The action button shows a share sheet with a custom activity that opens the course site inline in an `SFSafariViewController`.

You can also swipe-to-refresh manually.

{{< figure src="https://github.com/stoeffn/StudApp/raw/master/Screenshots/iPad-Pro-Courses.png" title="Screenshot: Course Overview" alt="Screenshot of StudApp" height="640" class="unframed">}}

### Announcements

One of the most-used features of _Stud.IP_ is announcements: An easy way for lecturers to share news with their students.

This is why they are also implemented in _StudApp_ and provide almost all formatting options, leveraging `WKWebView`s rendering powers. Nevertheless, fonts adapt to users' type size settings!

New announcements are highlighted automatically.

### Events

It is always important to know where to go next. This is why---since version 1.1---_StudApp_ supports events by providing a dedicated tab, which shows a user's next two weeks. Events not only include course, time, and location but also the topic of a lecture and a customizable subtitle. A custom date tab bar at the top lets one easily jump to specific dates.

Similarly, you can view a list of all events by course.

{{< figure src="https://github.com/stoeffn/StudApp/raw/master/Screenshots/iPhone-X-Events.png" title="Screenshot: Events" alt="Screenshot of StudApp" height="640" class="unframed">}}

### File Management

Browsing, downloading, and viewing documents is _StudApp_'s main purpose. Each course has associated with it a root folder that can contain nested folders and documents. Once uploaded by a lecturer, students can access their slides, exercise sheets, solutions, or other learning materials with just the tap of a finger. Previewing files makes use of the native _QuickLook_ capabilities.

Downloaded documents automatically appear in the corresponding tab, grouped by courses. You can also search documents by title, owner, and course.

To make availability obvious, inaccessible documents or folders are greyed out automatically, e.g. when a user's device is offline and a document is not downloaded.

_StudApp_ also highlights new files as well as those that have recently changed. User can also (un-)highlight manually.

Apart from regular files hosted by _Stud.IP_, the app supports downloading or linking to documents hosted by third parties and web links. It also guesses an appropriate file extension if none is given.

{{< figure src="https://github.com/stoeffn/StudApp/raw/master/Screenshots/iPhone-X-Downloads.png" title="Screenshot: Downloads" alt="Screenshot of StudApp" height="640" class="unframed">}}

### Privacy

Yes, privacy is a feature.

It is important to me to follow _Apple_'s lead and respect user privacy. I don't collect data and user data never leaves the device. Thus, _StudApp_ is completely independent from my server. Every synchronization feature is realized either via _Stud.IP_ or _CloudKit_. I have no way to access personal data. Additionally, the local database enjoys all of _iOS_'s default security mechanisms.

Sign-in utilizes _OAuth1_ so that there is no way for me to get near a password. All authentication tokens are, of course, stored securely in _Apple_'s _Keychain_. Furthermore, organizations can use their preferred authentication method in `SFAuthenticatedSession` or `SFSafariViewController` on `iOS 10`.

Due to a limitation in _Stud.IP 4.0_, the app has to spin up a local redirect server during the authorization process. There is no third-party server involved.

### System Integration

Native apps are only useful if they make use of the operating systems power instead of trying to mimic their web counterparts. Learn how _StudApp_ integrates with _iOS_!

#### Native Design

There is only one way to make an app feel natural: Use the native UI framework instead of a custom solution or a cross-platform lowest-common-denominator library.

That's why I use `UIKit` and adapt the overall design language of the system, following _Apple_'s [Human Interface Guidelines](https://developer.apple.com/ios/human-interface-guidelines/).

_StudApp_ also includes many optimizations for small screens like the _iPhone SE_'s as well as large ones like from the _iPad Pro_. Naturally, I utilize `UISplitViewController` and readable content guides.

#### File Provider

The app also includes a file provider, which makes course files available in the native _Files_ app—just like _iCloud Drive_!

I've made sure to support all convenience like tagging and marking something as favorite. And—like the main app—the file provider automatically refreshes contents and synchronizes with other targets using `NSPersistentHistory`.

#### Spotlight Indexing

Often, you need a specific document right away. You might remember part of its name but don't exactly know where to find it.

Thanks to _Spotlight_, this is not a problem with _StudApp_! Courses and documents are automatically indexed and removed from the index when appropriate. Even if a document isn't currently on the device, you can search from your home screen and view it. The app will take care of downloading it if needed.

#### Drag'n'Drop

Supporting _Drag'n'Drop_ for documents, folders, and textual data was a no-brainer because _UIKit_ made it very easy to implement. You can drag take a document and drop it on your _iCloud Drive_ desktop!

#### Handoff

My app supports handoff for both documents and courses. A user can seamlessly continue his activity on another _iOS_ device. If a document is not yet downloaded, _StudApp_ does it for you.

All activity eligable for handoff include a fallback URL that can be opened in _Safari_. Navigating to a course or downloading a document on your _Mac_ becomes as easy as a single click!

#### State Restoration

A more subtle feature is perhaps state restoration: When launching _StudApp_ after it has been terminated by the operating system, it tries to restore previous state so a user can continue what he was doing when he left the app.

#### 3D Touch

_StudApp_ supports _3D Touch_ (almost) everywhere—previewing folders, announcements, and documents is a breeze! It also has home screen and other quick actions that make navigation easier.

#### Haptic Feedback

When completing a task like downloading a document, _StudApp_ gives subtle haptic feedback to let a user know that he can now continue with his task.

### Accessibility

Accessibility doesn't just comprise optimizations for people who are visually impaired or have difficulties hearing: It means making your app usable by everybody. In the case of _Stud.IP_, this means supporting all kinds of organizations instead of making the app specific to just one university.

It is also important to ensure backwards compatibility for people with older devices and optimizations for all screen sizes. _StudApp_ requires at least _iOS 10_ and makes certain features available by providing them via menus instead of just gestures that only work on _iOS 11_ and higher or devices with _3D Touch_.

#### Full Internationalization

As there are many international students in _Germany_, providing multiple languages makes a significant difference. _StudApp_ supports _German_---my native language---as well as _English_. I'd be happy to find others who are willing to help with translating to other languages!

Another part of full internationalization is using the correct data formatters, which adapt to the user's preferred units and formats. I also took care of correct pluralization forms.

#### Dynamic Type

This is an _iOS_ system feature that lets users change their preferred font size. My app automatically adapts to the user's settings and even adjusts its layout for large accessibility fonts!

#### VoiceOver

_VoiceOver_ enables navigation using simple gestures or switch controls without needing to see the device's display. _StudApp_ is heavily optimized for it—it even correctly speaks colors in the color picker!

I also made sure to speak all information that is normally conveyed using visuals and implement custom accessibility actions where needed.

## Using StudApp

Do you want to add support for _StudApp_ at your university, school, club, or other kind of organization? Glad to hear that!

I've made it very easy for you:

1. Be administrator of a _Stud.IP_ instance of version 4 or higher
2. Activate the REST API
3. Generate _OAuth_ credentials
4. Give them to me in a secure way and I'll add your organization to _StudApp_ organization picker

> ###### Supporting StudApp at your organization doesn't cost a cent—how cool is that?
>
> If you want to support development, feel free to give a tip using the button in the in the app's about section. Thank you!

## Future

_Cornelis Kater_, _Rasmus Fuhse_, _Florian Herzog_, and I aim to make native apps an integral part of the _Stud.IP_ experience. I don't want to spoil to much but planned features include an instant messenger and push notifications.

There is more to come—be tuned for future updates!

## Architecture

If you want to know more about how _StudApp_ works, you've come to the right place! I'll give a general perspective on how things work.

> There are many topics that I've discussed in detail in other blog posts or will do so in the future. Give them a read if you like!
>
> You can also find more elaborate information as documentation comments in the source code. I encourage you to check it out!

### Patterns

This section gives a broad overview over design patterns used in _StudApp_ with the goal to make its code easy to understand and maintain.

#### Layout

_StudApp_ is divided into five distinct targets (and—where useful—accompanying testing targets):

**StudApp** is the actual iOS application with all view controllers and storyboards except those shared by multiple targets.

**StudKit** is a common framework containing all models, view models, and services. It is meant to be a common foundations for all targets, including potential _macOS_ apps.

**StudKitUI**, also a common framework, contains UI-related constants, views, and shared view controllers and storyboards.

**StudFileProvider** integrates with _Files_, which is _iOS_'s native file browser.

**StudFileProviderUI** displays user interfaces inside _Files_.

Each targets groups sources files logically instead of by type, sometimes nested. For instance, `Api`, `HttpMethods`, and `Result+Api` are all contained within one group. Extensions that operate on another framework's objects are grouped by framework.

#### MVVM

This project utilizes the [MVVM](https://de.wikipedia.org/wiki/Model_View_ViewModel) _"Model-View-ViewModel"_ pattern, which encourages separation of view and business logic and makes both easier to reuse and test. All models live in _StudKit_, e.g. in the form of database models and services. View models also reside in _StudKit_. Views and controllers form the View part of MVVM.

Using this approach as an addition to _Apple_'s _MVC_ actually makes a lot of sense for this project as I am able to reuse much of my view model logic in both the main app and the file provider. It also makes developing a potential _macOS_ app way easier.

#### Dependency Injection

Another pattern that _StudApp_ uses is [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection), which makes unit testing a lot easier. For example, I swap the real API class with a mock subclass that always returns specific responses.

I've implement a minimal approach that lets targets register instances for specific types at launch. Later, services can resolve these instances at runtime.

### Frameworks and Libraries

To give you a broad overview, here are the frameworks and libraries used in _StudApp_:

* `CloudKit`---Managing and updating organizations
* `CommonCrypto`---signing requests
* `CoreData`---persisting and organizing data
* `CoreGraphics`---drawing custom graphics like confetti or the loading indicator
* `CoreSpotlight`---indexing app content
* `FileProvider`---providing data to the _Files_ app
* `FileProviderUI`---showing UI in the _Files_ app
* `Foundation`---performing network requests and much more
* `MessageUI`---Showing a mail composer for feedback
* `MobileCoreServices`---dealing with file types
* `QuickLook`---previewing documents
* `SafariServices`---displaying websites inline and authorizing a user
* `StoreKit`---handling tipping
* `UIKit`---creating the _iOS_ app UI
* `WebKit`---rendering web-based content like announcements
* `XCTest`---testing my app

#### Why I Use Apple Frameworks Almost Exclusively

One of my personal goals with _StudApp_ is learning more about the exciting opportunities that _Apple_ frameworks provide. This is why I opted for first-party frameworks or implementing simple stuff myself instead of using a bunch of libraries.

Another concern I have is speed and security: Third-party libraries often come bloated with many features I'll never use and slow down app launch as [discussed in a WWDC16 talk](https://developer.apple.com/videos/play/wwdc2016/406/). Moreover, I cannot always verify the integrity and security of such libraries, whereas official _Apple_ frameworks go through more rigorous testing and quality assurance procedures.

## Testing

Ensuring quality requires automated testing. I use _XCTest_ to unit-test my models with a focus on parsing API responses as well as updating and fetching data.

I've created a way to automatically load mock data into _Core Data_ when running UI tests. Those tests will be automated in the future.

## Code and Licensing

As mentioned in the introduction, _StudApp_ is completely open source and licensed under _GPL-3.0_. You can find everything you need on [GitHub](https://github.com/stoeffn/StudApp)!

### Why I chose GPL

Since _StudApp_ is a complete software available on the _App Store_ and not a library, I want to encourage sharing improvements and prevent people from releasing their own closed source modified version since it took many months to build.

The thing about _GPL_ is that it requires source disclosure and forbids sublicencing, i.e. using something in a non-_GPL_-project. To that end, it is a perfect fit. Especially because _Stud.IP_ follows the same approach.

However, I appreciate feedback and contributions of any kind! It would also be great to find people excited about _Stud.IP_ who could help maintain this app in case I'm not able to.
