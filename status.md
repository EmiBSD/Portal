---
title: Status
description: Where the EmiBSD redesign stands, subsystem by subsystem - moved into the safe kernel crate, in progress, or still in the ported LandingZone tree.
---
# Status

**Pre-alpha.** EmiBSD boots in QEMU on arm64 and runs OpenBSD's userland, but most of the
kernel is still the 1:1 port inherited from LandingZone. amd64 builds are frozen until milestone
N10. There is no release.

The goal is a kernel with no `unsafe`: today the `kernel` and `abi` crates hold **0**, the
hardware layer `hal` holds 184 (each with a written proof), and the ported LandingZone tree,
`bsd`, still holds 9,490, falling as each subsystem moves out. Figures from the
[Kernel]({{ site.repo }}) repository at commit `b38843cf` (2026-10-23); the
[numbers per crate](#the-crates-today) are at the end of the page.

## What already works

Everything the port could do when Kernel split from it still works, and the redesign may not
change it. On arm64 in QEMU, with OpenBSD's own binaries:

- **System:** boot to `login:`, rc(8), ksh(1), ddb(4), multiprocessor boots on two and four CPUs.
- **Network:** ifconfig(8) and ping(8), pfctl(8), ipsecctl(8), TLS with ftp(1) and nc(1).
- **Storage:** FFS, tmpfs, FAT, ISO 9660, ext2fs and FUSE; softraid(4) RAID 0/1/5/6 and CRYPTO;
  NVMe and AHCI disks, USB storage.
- **Devices:** USB keyboards, audio, the frame buffer console.

Each line is checked by a scripted QEMU boot, the smoke tests, at every milestone close.

## Milestones

| Milestone | Scope | State |
|---|---|---|
| N0 Bootstrap | lineage records, tooling, the `unsafe` budget, the baseline | <span class="state state-done">done</span> 2026-10-09 |
| N1 Leaves | libkern, libz, the crypto primitives | <span class="state state-done">done</span> 2026-10-09 |
| N2 Foundations | the `kernel`, `abi` and `hal` crates, the runtime, pipe(2) | <span class="state state-done">done</span> 2026-10-16 |
| N3 Memory | uvm into `kernel::vm`, the pmaps into `hal` | <span class="state state-done">done</span> 2026-10-18 |
| N4 Processes and scheduling | timeouts, processes, descriptors, kqueue, the scheduler, signals, tty, clocks, sysctl | <span class="state state-wip">in progress</span> (every slice merged; the close next) |
| N5 VFS and file systems | the VFS layer, ufs, nfs, tmpfs, msdosfs, cd9660, ntfs | <span class="state state-todo">pending</span> |
| N6 Network stack | interfaces, routing, IPv4, IPv6, sockets | <span class="state state-todo">pending</span> |
| N7 Devices | the driver model, then every bus and driver | <span class="state state-todo">pending</span> |
| N8 Security subsystems | pf, IPsec, WireGuard, pledge, unveil, exec, the crypto framework | <span class="state state-todo">pending</span> |
| N9 Close | the last of the LandingZone tree deleted, on arm64 | <span class="state state-todo">pending</span> |
| N10 amd64 | the frozen amd64 tree brought up to date | <span class="state state-todo">pending</span> |
| N11 Verification | semantic `unsafe` count, idiomaticity scoring, OpenBSD's regress suite | <span class="state state-todo">pending</span> |
| N12 Performance | the slowdowns left open after N3, on both architectures | <span class="state state-todo">pending</span> |

## N4, the milestone in progress

N4 moves processes and scheduling out of the LandingZone tree, one slice at a time; each slice
is merged into Kernel's `main` after its review. The milestone closes when `sys/kern/` holds only
the VFS, socket and security files of later milestones, and the full test suite passes.

| Slice | What moves | State | Merged |
|---|---|---|---|
| N4.0 | Only arm64 built, booted and measured until N10 (the `EMIBSD_ARCHS` switch) | <span class="state state-done">done</span> | 2026-10-21 `7bfcdfe4` |
| N4.1 | timeout(9), task(9), extent(9) | <span class="state state-done">done</span> | 2026-10-21 `e267f8f7` |
| N4.2 | Processes, credentials, resource limits | <span class="state state-done">done</span> | 2026-10-22 `2afaf4ff` |
| N4.3 | File descriptors | <span class="state state-done">done</span> | 2026-10-22 `dfda0cd1` |
| N4.4 | kqueue, select(2), poll(2) | <span class="state state-done">done</span> | 2026-10-22 `f2639a31` |
| N4.4b | The kqueue filters as a Rust trait (`Filter<G>`) | <span class="state state-done">done</span> | 2026-10-22 `e18b851b` |
| N4.5a | The scheduler in `kernel`; the context switch and the per-CPU core in `hal` | <span class="state state-done">done</span> | 2026-10-22 `5c81b501` |
| N4.5b+c | Signals and SIGIO; spl, soft interrupts, the kernel lock and the mutex in `hal` | <span class="state state-done">done</span> | 2026-10-22 `0e871047` |
| N4.6a | fork, exit, the credential and resource calls, accounting | <span class="state state-done">done</span> | 2026-10-23 `decb50c0` |
| N4.6b | sysctl(2)'s core | <span class="state state-done">done</span> | 2026-10-23 `68dafea0` |
| N4.6c | futex(2) | <span class="state state-done">done</span> | 2026-10-22 `cb1b9192` |
| N4.7a | The message buffer, /dev/klog, sendsyslog(2) | <span class="state state-done">done</span> | 2026-10-22 `ae0637ec` |
| N4.7b | Terminals, clists, line disciplines, pseudo-terminals | <span class="state state-done">done</span> | 2026-10-23 `86c282a0` |
| N4.8a | Clocks and timecounters | <span class="state state-done">done</span> | 2026-10-23 `53c4248f` |
| a6 | The time system calls and reboot(2) handled natively | <span class="state state-done">done</span> | 2026-10-23 `480c82e1` |
| N4.8b | Traps, the system-call entry, copyin/copyout (arm64); a security-reviewed area | <span class="state state-done">done</span> | 2026-10-23 `d58ce5c6` |
| N4.8d | Kernel page-table isolation (KPTI) for arm64 | <span class="state state-done">done</span> | 2026-10-23 `b38843cf` |
| Close | `just check`, `just ci`, `just ci-full` and `diff-openbsd` green; the tag `n4-processes` | <span class="state state-todo">pending</span> |  |

Some moved parts still leave a thinner file in `bsd` that connects the code not yet moved to the
new one; it goes when its last caller moves. Later milestones are listed above; each gets a
table like this one when it starts.

## The crates today

Files and `unsafe` counts printed by `cargo xtask unsafe-report` at `b38843cf`.

| Crate | Files | `unsafe` | Note |
|---|---:|---:|---|
| `kernel` | 88 | 0 | `#![forbid(unsafe_code)]`: the compiler refuses any |
| `abi` | 4 | 0 | `#![forbid(unsafe_code)]`; 105 of the 331 system-call entries handled natively |
| `hal` | 145 | 184 | the only crate allowed `unsafe`, each site with a written proof |
| `bsd` (the LandingZone tree) | 1,049 | 9,490 | shrinks as subsystems move out; deleted at N9 |

The detailed plan, with each milestone's exit criterion, is
[ROADMAP.md]({{ site.repo }}/blob/main/docs/ROADMAP.md) in the Kernel repository; the day-to-day state
is [STATUS.md]({{ site.repo }}/blob/main/docs/STATUS.md).
