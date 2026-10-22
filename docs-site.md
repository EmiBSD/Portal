---
title: Docs
permalink: /docs/
description: How to build EmiBSD, boot it in QEMU, run its tests, and find your way around its crates.
---
# Docs

## Build and run

The documented host is macOS on Apple Silicon. You need `rustup`, QEMU, Limine and `just`;
the repository pins a stable Rust toolchain and installs it, with both bare-metal targets, on
the first `cargo` command. No nightly features are used.

```sh
brew install rustup qemu limine just
git clone {{ site.repo }}
cd EmiBSD
just build        # the kernel for the architectures in EMIBSD_ARCHS (arm64 by default)
just run-arm64    # boot it in QEMU, serial console on stdio
```

Until milestone N10, only arm64 is built and tested; amd64 is frozen and its boots are reported
as skipped. The step-by-step setup, including the toolchain for OpenBSD's userland, is
[docs/SETUP.md]({{ site.repo }}/blob/main/docs/SETUP.md) in the repository.

## Test

| Command | What it does |
|---|---|
| `just test` | host unit tests, run on the development machine |
| `just test-ref` | constants cross-checked against OpenBSD's C headers |
| `just smoke` | boots in QEMU, headless, asserting serial output and exit codes |
| `just clippy` / `just fmt` | lints with warnings as errors, and the format check |
| `just check` | build, clippy, fmt, the lineage and `unsafe` checks, and the host tests |
| `just ci` | all of the above, every smoke, and the comparison with OpenBSD |
| `just diff-openbsd` | the same scenarios on EmiBSD and on a real OpenBSD, compared step by step |

QEMU is always started through `just` or `cargo xtask`, never by hand: the recipes pick the
firmware, the disks and the expected output.

## Tree layout

```
sys/kernel/      crate kernel: every decision of the OS; #![forbid(unsafe_code)]
sys/abi/         crate abi: OpenBSD's system-call interface, the module abi_openbsd.ko; forbid, no logic
sys/hal/         crate hal: the hardware (arch/arm64, arch/amd64, machine) and the runtime; the only unsafe
sys/             package bsd: the LZ tree (kern, dev, net, netinet, ufs, ...), replaced subsystem by subsystem
sys/stand/       the boot loaders: boot(8) and efiboot, separate binaries
sys/lib/         leaf crates: libkern, libz
tools/xtask/     host tooling: image, qemu, smoke, lz, unsafe-report, diff-openbsd, ...
lineage.toml     what every Rust file derives from in EmiBSD.LZ
lz-sync.toml     one triage record per LZ commit after the pin
```

Generic code (`kern`, `dev`, `net`, ...) reaches architecture code only through one interface,
`crate::machine`; the two architectures never appear outside `sys/arch/` and `sys/machine/`.

The kernel boots from its own boot(8) and efiboot, or from Limine, and runs OpenBSD's userland
from a ramdisk or from an installed disk.

## Further reading in the repository

These are the project's working documents; they change with every milestone.

- [ARCHITECTURE.md]({{ site.repo }}/blob/main/docs/ARCHITECTURE.md): the design, crate by crate.
- [ZERO_UNSAFE.md]({{ site.repo }}/blob/main/docs/ZERO_UNSAFE.md): the plan for a kernel with no `unsafe`, and its one diagram.
- [ROADMAP.md]({{ site.repo }}/blob/main/docs/ROADMAP.md): milestones N0 to N12 and their exit criteria.
- [PHASE2.md]({{ site.repo }}/blob/main/docs/PHASE2.md): the process and the decisions log.
- [IDIOMS.md]({{ site.repo }}/blob/main/docs/IDIOMS.md): how a C-shaped pattern becomes a Rust one.
- [JOURNAL.md]({{ site.repo }}/blob/main/docs/JOURNAL.md): what worked and what failed, milestone by milestone.
