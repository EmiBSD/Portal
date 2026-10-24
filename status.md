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
[Kernel]({{ site.repo }}) repository at commit `2d779661` (2026-10-24), the close of N4; the
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
| N4 Processes and scheduling | timeouts, processes, descriptors, kqueue, the scheduler, signals, tty, clocks, sysctl | <span class="state state-done">done</span> 2026-10-24 |
| N5 VFS and file systems | the VFS layer, ufs, nfs, tmpfs, msdosfs, cd9660, ntfs | <span class="state state-todo">pending</span> |
| N6 Network stack | interfaces, routing, IPv4, IPv6, sockets | <span class="state state-todo">pending</span> |
| N7 Devices | the driver model, then every bus and driver | <span class="state state-todo">pending</span> |
| N8 Security subsystems | pf, IPsec, WireGuard, pledge, unveil, exec, the crypto framework | <span class="state state-todo">pending</span> |
| N9 Close | the last of the LandingZone tree deleted, on arm64 | <span class="state state-todo">pending</span> |
| N10 amd64 | the frozen amd64 tree brought up to date | <span class="state state-todo">pending</span> |
| N11 Verification | semantic `unsafe` count, idiomaticity scoring, OpenBSD's regress suite | <span class="state state-todo">pending</span> |
| N12 Performance | the slowdowns left open after N3, on both architectures | <span class="state state-todo">pending</span> |

## N5, the next milestone

N5 moves the VFS and the file systems out of the LandingZone tree into `kernel::fs`. It closes
when `sys/kern/vfs_*` and the `sys/ufs/`, `sys/nfs/`, `sys/isofs/`, `sys/msdosfs/`,
`sys/ntfs/`, `sys/tmpfs/` and `sys/miscfs/` directories are gone from `bsd` (the plan counted
816 `unsafe` in 134 files there), and the full test suite passes. The plan is Kernel's
[`docs/ZERO_UNSAFE.md`]({{ site.repo }}/blob/main/docs/ZERO_UNSAFE.md) section 0.8; as in N4,
a slice may be split or renumbered when it starts, and this table follows.

| Slice | What moves | State |
|---|---|---|
| first | The five bridges N4 left open (`Uptime`, `SysInfo`, `VmProc`, `PipeGlue`, `PipeFiles`) | <span class="state state-todo">pending</span> |
| first | The buffer queues (`kern_bufq`) over a typed `Buf` | <span class="state state-todo">pending</span> |
| 1 | The VFS core: `vfs_subr`, `vfs_bio`, `vfs_lockf`, `vfs_syscalls`, `vfs_lookup`, `vfs_vnops`, `vfs_cache`, `vfs_init`, `vfs_sync`, `vfs_getcwd`, `vfs_vops`, `vfs_default`, `spec_vnops`; the vnode and mount operations as Rust traits | <span class="state state-todo">pending</span> |
| 2 | `ufs`, `ffs` and `ext2fs` (43 files) | <span class="state state-todo">pending</span> |
| 3 | `nfs` (24 files), over the sockets still in `bsd` until N6 | <span class="state state-todo">pending</span> |
| 4 | `isofs`: cd9660 and udf (16 files) | <span class="state state-todo">pending</span> |
| 5 | `msdosfs` (12 files) and `ntfs` (9 files) | <span class="state state-todo">pending</span> |
| 6 | `miscfs`: fuse, fifofs, deadfs (10 files), and `tmpfs` (7 files) | <span class="state state-todo">pending</span> |
| Close | `just check`, `just ci`, `just ci-full` and `diff-openbsd` green; the tag `n5-vfs` | <span class="state state-todo">pending</span> |

N4, the milestone before, closed on 2026-10-24 in seventeen slices; its results, and what it
cost in speed, are in [its news entry]({{ '/news/2026/10/24/n4-met/' | relative_url }}).

## The crates today

Files and `unsafe` counts printed by `cargo xtask unsafe-report` at `2d779661`.

| Crate | Files | `unsafe` | Note |
|---|---:|---:|---|
| `kernel` | 88 | 0 | `#![forbid(unsafe_code)]`: the compiler refuses any |
| `abi` | 4 | 0 | `#![forbid(unsafe_code)]`; 105 of the 331 system-call entries handled natively |
| `hal` | 145 | 184 | the only crate allowed `unsafe`, each site with a written proof |
| `bsd` (the LandingZone tree) | 1,049 | 9,490 | shrinks as subsystems move out; deleted at N9 |

The detailed plan, with each milestone's exit criterion, is
[ROADMAP.md]({{ site.repo }}/blob/main/docs/ROADMAP.md) in the Kernel repository; the day-to-day state
is [STATUS.md]({{ site.repo }}/blob/main/docs/STATUS.md).
