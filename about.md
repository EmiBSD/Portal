---
title: About
description: Why EmiBSD exists, how it started, its philosophy of fidelity first and optimisation after, its relation to OpenBSD, and what Rust brings.
---
# About EmiBSD

## Why it exists

EmiBSD asks a concrete question: can a mature, security-minded C kernel be carried into Rust
without losing any of its behaviour, and then rebuilt so that the compiler, not a reviewer,
rules out most memory errors?

OpenBSD is the kernel chosen for the experiment. Its code is coherent and carefully written, its
behaviour is well documented in its manual pages, and it comes with a complete userland. That
userland is the test: if OpenBSD's own unmodified binaries boot, log in, mount disks, filter
packets and run TLS on the Rust kernel, the port is doing its job.

## How it started

That question came second. EmiBSD began as a proof of concept for a broader one: how far can
an AI-assisted migration, run with Claude Code, go on a genuinely hard problem? A kernel was
chosen because it is about as hard as migrations get: a large, long-lived, concurrent code
base, with hardware underneath, a whole userland on top, and no room for an approximate
result.

There was also a personal reason. OpenBSD is the maintainer's favourite operating system, and
EmiBSD is an attempt to keep what makes it so: the same system, with the same behaviour, in a
language designed for memory safety. It does not set out to replace OpenBSD. It is one
person's reading of OpenBSD's essence, carried into Rust.

The process grew with the experiment: written rules, agents with fixed roles, every step
checked against OpenBSD's behaviour, one maintainer taking the decisions. How it works today is
described on the [Process]({{ '/process/' | relative_url }}) page.

## Fidelity first, optimisation after

The kernel's work happens in two stages, in two repositories:

1. **Fidelity.** [LandingZone]({{ site.repo_lz }}) (formerly EmiBSD.LZ) is a file-by-file port of the OpenBSD kernel to
   Rust. It keeps the C's structure, names and control flow, so every Rust file can be checked
   against the C file it came from.
2. **Redesign.** [Kernel]({{ site.repo }}) takes what LandingZone ported and rebuilds the inside, one
   subsystem at a time, with Rust's ownership in place of the C's conventions.

Two more repositories sit around the kernel: [Userland]({{ site.repo_userland }}), the base
system above it, one tree where every program is placed by what it does; and
[DevTools]({{ site.repo_devtools }}), the toolchains that build everything, imported and built
once. The [Process]({{ '/process/' | relative_url }}) page describes each.

Three things are never traded away during the redesign:

- **What userland sees.** The system-call ABI, the sysctl names, the ioctls and the device
  numbers stay byte-identical. OpenBSD's userland runs unmodified.
- **Measured behaviour.** Every change is checked against boots in QEMU and against the same
  scenarios run on a real OpenBSD. See [Process]({{ '/process/' | relative_url }}).
- **Provenance and licences.** Every file says which LandingZone files (and so which OpenBSD C files) it
  derives from, and keeps their copyright notices whole.

The goals, in priority order: safety, then maintainability, then performance. A performance
gain is accepted only when it is measured, and never at the cost of the first two.

## Relation to OpenBSD

EmiBSD is **not** an official OpenBSD fork, and it is not affiliated with or endorsed by the
OpenBSD project. It is an independent experiment built on OpenBSD's source code.

- OpenBSD's C source, at a pinned -current snapshot, is the specification. When the Rust
  behaves differently from OpenBSD, the Rust is wrong.
- The userland is OpenBSD's own, compiled from its source without changes.
- The system reports itself to userland as `EmiBSD 8.0`.
- Files derived from OpenBSD keep their original BSD, ISC and other licence notices; new code
  is ISC.

If you want a secure, supported operating system, use [OpenBSD](https://www.openbsd.org/).

## What Rust brings

- **Unsafe code confined by the compiler.** The kernel is being split into crates. `kernel`
  (every decision of the OS) and `abi` (the system-call interface) carry
  `#![forbid(unsafe_code)]`: the compiler refuses to build them with a single `unsafe` block.
  Of the new crates, only `hal`, the hardware layer, may contain `unsafe`, and every site there
  has a written soundness argument. The ported LandingZone tree, still most of the kernel today, keeps
  its `unsafe` until each subsystem is replaced; the [Status]({{ '/status/' | relative_url }})
  page has the numbers.
- **Locks that own their data.** In the redesigned code, a structure guarded by a lock lives
  inside that lock, so code cannot touch it without holding it.
- **Errors in the type.** Functions return `Result<T, Errno>` instead of an integer plus
  out-parameters, so an error cannot be dropped silently.
- **Typed user memory.** Copies to and from user space go through typed pointers, not raw
  addresses.
- **Host tests.** Much of the kernel's logic also builds for macOS and runs there as ordinary
  unit tests, thousands of them, before anything boots.

Rust does not make a kernel correct. It moves a class of bugs (use after free, data races,
out-of-bounds access) from review to compile time, in the parts written in safe Rust. The rest
is tested the old way.

## The mascot

Ferffy is a southern king crab, the child of Ferris, Rust's crab, and Puffy, OpenBSD's
pufferfish: the claws from one parent, the spikes from the other. It is an original drawing
inspired by both.

## Thanks

EmiBSD would not exist without the OpenBSD project and its community. Decades of careful,
patient work went into a kernel written to be read, a userland that is complete and coherent,
manual pages that say what the code actually does, and a culture that treats correctness and
security as the default rather than as a feature. That work is the ground this project stands
on, and the reason it could be attempted at all.

To every OpenBSD developer, past and present, and to everyone who has tested, reported,
documented and supported it: thank you. Whatever EmiBSD gets right, it learned from you;
whatever it gets wrong is its own.
