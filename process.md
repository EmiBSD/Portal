---
title: Process
description: The EmiBSD pipeline - EmiBSD.LZ as the 1:1 landing zone, EmiBSD as the redesigned system, the migration agents, and how the work to optimise is chosen.
---
# Process

## The pipeline

```
OpenBSD C (-current, pinned)      the specification
        │  ported file by file
        ▼
EmiBSD.LZ                         the landing zone: a 1:1 port, C's shape in Rust
        │  synced commit by commit
        ▼
EmiBSD                            the redesign: same behaviour, Rust's shape inside
```

### EmiBSD.LZ, the landing zone

[EmiBSD.LZ]({{ site.repo_lz }}) ports the OpenBSD kernel to Rust one C file at a time. Each Rust
file names the C file it came from and keeps its structure, so a reader can hold the two side by
side. LZ's job is fidelity: it boots OpenBSD's userland, and its own milestones (M0 onwards)
track which parts of the C are ported.

### EmiBSD, the redesign

EmiBSD started from LZ's tree on 2026-10-09 and has been rebuilding it since. The target is
four pieces:

| Crate | Path | What it holds | `unsafe` |
|---|---|---|---|
| `kernel` | `sys/kernel/` | every decision of the OS | forbidden by the compiler |
| `abi` | `sys/abi/` | OpenBSD's system-call interface, loaded as the module `abi_openbsd.ko` | forbidden by the compiler |
| `hal` | `sys/hal/` | the hardware and the runtime (locks, pools, user copies) | allowed, each site proved |
| `bsd` | `sys/` | the LZ tree still being replaced | inherited from LZ, deleted at the end |

A subsystem leaves `bsd` when it is redesigned into `kernel`, written from the C's behaviour with
LZ's code as the reference. What it still needs from code that has not moved goes through a
narrow, registered bridge, never a direct call.

LZ keeps porting after the split. Every LZ commit is triaged here: applied, re-implemented in
the new shape, already covered by the redesign, or not applicable, with the reason recorded.
A security fix is never skipped silently.

### Provenance

Every Rust file under `sys/` is listed in `lineage.toml` with the LZ files it derives from, and
its status: `inherited` (byte for byte LZ's), `adapted` (only its call sites changed) or
`redesigned`. Every function an LZ file had is accounted for: kept, renamed, split, merged or
dropped with a reason. The tooling can answer where any LZ or OpenBSD function went.

## The migration agent

The redesign is carried out by AI coding agents (Claude Code), each with a fixed role and a
shared rulebook that lives in the repository. One human maintainer takes the decisions: scope,
dependencies, the `unsafe` ceilings, anything userland could see. They see every plan and
approve every commit.

| Role | Does |
|---|---|
| surveyor | a read-only inventory of a module: every `unsafe`, its callers, the C's constraints, the tests that cover it |
| planner | the design brief: types, ownership, locks, the commit series, and the questions for the maintainer |
| redesigner | writes the new module in its own branch, with tests, and records its lineage |
| reviewer | an independent review: behaviour kept, `unsafe` arguments, security invariants |
| integrator | merges the branches and runs the full test suite |
| debugger | finds the root cause of a failing or flaky test without weakening it |

Agents that write code work in separate git worktrees. Lessons that outlive one run are kept
as short notes, committed with the tree, so the next agent starts from them.

## How the work is chosen

- **By milestone.** The roadmap orders the subsystems: the leaves first (string routines, zlib,
  crypto primitives), then the foundations, memory, processes, file systems, network and
  devices, and the security subsystems (pf, IPsec, WireGuard, pledge, unveil, exec) last, with
  extra review. See [Status]({{ '/status/' | relative_url }}).
- **One module at a time.** The unit of work is one module of one subsystem. Before a line is
  written, the LZ module and the C behind it are read completely.
- **Safety first.** The first measure of progress is `unsafe` removed from the kernel, counted
  by a tool and capped by budgets that only the maintainer can raise.
- **Performance only when measured.** On a hot path (the page fault, fork, exec, mmap, the
  scheduler), host microbenchmarks run before each commit; an operation more than 10 % slower
  without a written reason stops the work until the maintainer decides.

## How a change is checked

- **Boots in QEMU.** Each milestone closes with the full set of smoke tests: 86
  scripted boots that drive OpenBSD's own binaries (login, disks, softraid, pf, IPsec, TLS,
  USB, audio, multiprocessor stress) and compare their serial output.
- **Against OpenBSD itself.** `diff-openbsd` runs the same scenarios on EmiBSD and on a real
  OpenBSD in QEMU and compares them step by step. Each known difference is listed with its
  reason; no new one is allowed.
- **Host tests.** Thousands of unit tests run on the development machine.
- **Lineage and budgets.** Tools check that every file's provenance is recorded and that no
  subsystem's `unsafe` count rose.
