---
title: The repositories move to the EmiBSD organisation
date: 2026-10-22 20:00:00 +0000
description: EmiBSD.LZ is now LandingZone, the native system is now Kernel, both under github.com/EmiBSD.
---
EmiBSD's code now lives in its own GitHub organisation,
[github.com/EmiBSD](https://github.com/EmiBSD), under new names:

- **[LandingZone]({{ site.repo_lz }})**, formerly EmiBSD.LZ: the file-by-file port of the
  OpenBSD kernel to Rust.
- **[Kernel]({{ site.repo }})**: the redesign of that port, the system this site describes.

GitHub redirects the old URLs. Nothing else changed: the history, the milestones and the
LandingZone commit that Kernel is synced to are the same.

On the same day Kernel merged N4.5a: the context switch, the per-CPU core and the scheduler
lock moved into `hal`, and the sleep and run queues, the idle loop, the priorities and kernel
threads into the `kernel` crate. The [Status]({{ '/status/' | relative_url }}) page has the new
numbers.
