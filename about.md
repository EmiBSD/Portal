---
title: About
description: Why EmiBSD exists, its philosophy of fidelity first and optimisation after, its relation to OpenBSD, and what Rust brings.
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

## Fidelity first, optimisation after

The work happens in two stages, in two repositories:

1. **Fidelity.** [LandingZone]({{ site.repo_lz }}) (formerly EmiBSD.LZ) is a file-by-file port of the OpenBSD kernel to
   Rust. It keeps the C's structure, names and control flow, so every Rust file can be checked
   against the C file it came from.
2. **Redesign.** [Kernel]({{ site.repo }}) takes what LandingZone ported and rebuilds the inside, one
   subsystem at a time, with Rust's ownership in place of the C's conventions.

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
