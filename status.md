---
title: Status
description: Where the EmiBSD redesign stands, subsystem by subsystem - moved into the safe kernel crate, in progress, or still in the ported LZ tree.
---
# Status

**Pre-alpha.** EmiBSD boots in QEMU on arm64 and runs OpenBSD's userland, but most of the
kernel is still the 1:1 port inherited from EmiBSD.LZ. amd64 builds are frozen until milestone
N10. There is no release.

The tables below come from the repository at commit `93a8e653` (2026-10-22): the files in each
crate and directory, and the `unsafe` counts printed by `cargo xtask unsafe-report`.

## The crates today

| Crate | Files | `unsafe` | Note |
|---|---:|---:|---|
| `kernel` | 65 | 0 | `#![forbid(unsafe_code)]`: the compiler refuses any |
| `abi` | 4 | 0 | `#![forbid(unsafe_code)]`; 44 of the 331 system-call entries handled natively |
| `hal` | 117 | 122 | the only crate allowed `unsafe`, each site with a written proof |
| `bsd` (the LZ tree) | 1,064 | 9,808 | shrinks as subsystems move out; deleted at N9 |

## Milestones

| Milestone | Scope | State |
|---|---|---|
| N0 Bootstrap | lineage records, tooling, the `unsafe` budget, the baseline | <span class="state state-done">done</span> 2026-10-09 |
| N1 Leaves | libkern, libz, the crypto primitives | <span class="state state-done">done</span> 2026-10-09 |
| N2 Foundations | the `kernel`, `abi` and `hal` crates, the runtime, pipe(2) | <span class="state state-done">done</span> 2026-10-16 |
| N3 Memory | uvm into `kernel::vm`, the pmaps into `hal` | <span class="state state-done">done</span> 2026-10-18 |
| N4 Processes and scheduling | timeouts, processes, descriptors, kqueue, the scheduler, signals, tty | <span class="state state-wip">in progress</span> |
| N5 VFS and file systems | the VFS layer, ufs, nfs, tmpfs, msdosfs, cd9660, ntfs | <span class="state state-todo">pending</span> |
| N6 Network stack | interfaces, routing, IPv4, IPv6, sockets | <span class="state state-todo">pending</span> |
| N7 Devices | the driver model, then every bus and driver | <span class="state state-todo">pending</span> |
| N8 Security subsystems | pf, IPsec, WireGuard, pledge, unveil, exec, the crypto framework | <span class="state state-todo">pending</span> |
| N9 Close | the last of the LZ tree deleted, on arm64 | <span class="state state-todo">pending</span> |
| N10 amd64 | the frozen amd64 tree brought up to date | <span class="state state-todo">pending</span> |
| N11 Verification | semantic `unsafe` count, idiomaticity scoring, OpenBSD's regress suite | <span class="state state-todo">pending</span> |
| N12 Performance | the slowdowns left open after N3, on both architectures | <span class="state state-todo">pending</span> |

## Subsystems

### Moved into the safe crates

| Subsystem | Now in | From | Milestone |
|---|---|---|---|
| Crypto primitives (ciphers, hashes, MACs) | `sys/kernel/crypto/` (20 files) | `sys/crypto/` | <span class="state state-done">done</span> N2 |
| pipe(2) | `sys/kernel/pipe.rs` | `sys/kern/sys_pipe.rs` | <span class="state state-done">done</span> N2 |
| Virtual memory (uvm) | `sys/kernel/vm/` (23 files) | `sys/uvm/` | <span class="state state-done">done</span> N3 |
| Physical maps (pmap) | `sys/hal/pmap.rs` and `sys/hal/arch/` | `sys/arch/*/pmap*` | <span class="state state-done">done</span> N3 |
| timeout(9), task(9), extent(9) | `timeout.rs`, `task.rs`, `extent.rs` | `sys/kern/` | <span class="state state-done">done</span> N4.1 |
| Processes, credentials, limits | `proc.rs`, `cred.rs`, `resource.rs` | `sys/kern/` | <span class="state state-done">done</span> N4.2 |
| File descriptors | `file.rs`, `descrip.rs`, `uio.rs` | `sys/kern/kern_descrip.rs` | <span class="state state-done">done</span> N4.3 |
| kqueue, select(2), poll(2) | `event.rs`, `select.rs` | `sys/kern/kern_event.rs`, `sys/kern/sys_generic.rs` | <span class="state state-done">done</span> N4.4 |
| Runtime: locks, pools, malloc, per-CPU data, user copies, module loader | `sys/hal/` | new | <span class="state state-done">done</span> N2–N3 |

Some of these still leave a thinner file in `bsd` that connects the code not yet moved to the
new one (`kern_event.rs`, `kern_descrip.rs`, `sys_generic.rs`, `kern_prot.rs`); it goes when
its last caller moves.

### In progress and pending

| Subsystem | Still in `bsd` | Milestone |
|---|---|---|
| Scheduler, sleep queues, kernel threads | `sys/kern/kern_sched.rs`, `sched_bsd.rs`, `kern_synch.rs`, `kern_kthread.rs` | <span class="state state-wip">in progress</span> N4 |
| fork, exit, signals | `sys/kern/kern_fork.rs`, `kern_exit.rs`, `kern_sig.rs` | <span class="state state-todo">pending</span> N4 |
| Clocks and time | `sys/kern/kern_clock.rs`, `kern_clockintr.rs`, `kern_tc.rs`, `kern_time.rs` | <span class="state state-todo">pending</span> N4 |
| sysctl(2) core | `sys/kern/kern_sysctl.rs` | <span class="state state-todo">pending</span> N4 |
| Terminals and pseudo-terminals | `sys/kern/tty*.rs` (5 files) | <span class="state state-todo">pending</span> N4 |
| CPU, traps, system-call entry, copyin/copyout (arm64) | `sys/arch/arm64/` | <span class="state state-todo">pending</span> N4 |
| VFS layer | `sys/kern/vfs_*.rs` and `spec_vnops.rs` (14 files) | <span class="state state-todo">pending</span> N5 |
| File systems | `sys/ufs/` (48), `sys/nfs/` (25), `sys/isofs/` (19), `sys/msdosfs/` (13), `sys/miscfs/` (13), `sys/ntfs/` (10), `sys/tmpfs/` (8) | <span class="state state-todo">pending</span> N5 |
| Network stack | `sys/net/` (44), `sys/netinet/` (45), `sys/netinet6/` (26), sockets in `sys/kern/` (9) | <span class="state state-todo">pending</span> N6 |
| Devices | `sys/dev/` (398), `sys/scsi/` (11), the bus and autoconf glue of `sys/arch/` | <span class="state state-todo">pending</span> N7 |
| Security subsystems | pf, IPsec, WireGuard, softraid CRYPTO; `kern_pledge.rs`, `kern_unveil.rs`, `exec_*.rs`; the crypto framework in `sys/crypto/` (14) | <span class="state state-todo">pending</span> N8 |
| What is left | `sys/ddb/` (11), `sys/conf/` (4), the headers of `sys/sys/` (83), the old pool, malloc and lock code | <span class="state state-todo">pending</span> N9 |
| amd64 | `sys/arch/amd64/`, `sys/hal/arch/amd64/` (frozen) | <span class="state state-todo">pending</span> N10 |

Network and security directories list every file they hold today; the files of N8 leave last.
File counts are `.rs` files.

## What already works

Everything the port could do when EmiBSD split from it still works, and the redesign may not
change it. On arm64 in QEMU, with OpenBSD's own binaries: boot to `login:`, ksh(1), rc(8),
ifconfig(8) and ping(8), pfctl(8) and ipsecctl(8), TLS with ftp(1) and nc(1), FFS, tmpfs, FAT,
ISO 9660, ext2fs and FUSE, softraid(4) RAID 0/1/5/6 and CRYPTO, NVMe, AHCI, USB storage and
keyboards, audio, the frame buffer console, ddb(4), and multiprocessor boots on two and four
CPUs.

The detailed plan, with each milestone's exit criterion, is
[ROADMAP.md]({{ site.repo }}/blob/main/docs/ROADMAP.md) in the repository; the day-to-day state
is [STATUS.md]({{ site.repo }}/blob/main/docs/STATUS.md).
