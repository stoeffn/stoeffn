---
title: "Golden Gate"
description: "Logic gate playground and my WWDC18 scholarship submission."
date: 2018-05-16T11:39:49+02:00
draft: false
---

Just like the year before, _Apple_ offered a _WWDC_ ticket to students, who submitted outstanding visually interactive _Swift Playgrounds_.

In this post, I'd like to show what I've created for my submission: A logic gate simulator in the _WWDC18_ theme that features several puzzles as well as a sandbox and some advanced creations.

You can play around with the [source code on _GitHub_](https://github.com/stoeffn/GoldenGate/)!
<!--more-->

{{< figure src="../images/golden-gate/introduction.png" title="Screenshot: Introduction to Digital Circuits" alt="Screenshot of Golden Gate" width="768" class="unframed">}}

At its core, my _Swift Playground Book_ comprises a logic simulator with accompanying puzzles and explanations as well as a solution checker, which doesn’t look for specific components but rather simulates the learner’s circuit and asserts expected outputs for various input states. Thus, it is possible to check progress without discouraging alternative solutions.

The simulator itself is dynamic in a way that lets it update passive components while being modified, which makes for instant visual feedback. Active components update their outputs at a fixed rate and also simulate propagation delay. In other words, my logic simulator also supports feedback loops that enable flip-flops or clocks.

{{< figure src="../images/golden-gate/flip-flop.png" title="Screenshot: RS-Flip-Flop" alt="Screenshot of Golden Gate" width="768" class="unframed">}}

It is built on top of lightweight _Swift_ structs and heavily uses language features such as protocol extensions and synthesized protocol conformance. Thus, it was a breeze to implement `Codable` support for loading and saving levels as _JSON_.

This is why I also developed a document-based _macOS_ sandbox application with `AppKit` for content creation. It was very easy to reuse code on both _macOS_ and _iOS_ since I’ve employed _SceneKit_ to visualize the logic simulation.

Even though I’ve never touched _SceneKit_ before, it was a great learning experience getting started. I created my textures and images in [_Sketch_](https://www.sketchapp.com/) and geometries in [_Blender_](http://blender.org). Another integral part to my process was—of course—the _Xcode Scene Editor_.

Adding and moving circuit components on _iOS_ couldn’t be easier—thanks to _iOS_ 11’s new drag’n’drop API. Triggering and removing components is based on gesture recognizers.

**Thanks for your interest!**

If you like my content, I would be honored if you gave my website a star on [GitHub](https://github.com/stoeffn/stoeffn)!