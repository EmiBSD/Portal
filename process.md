---
title: Process
description: The EmiBSD pipeline - LandingZone as the 1:1 port, Kernel as the redesigned system, Userland and DevTools around it, the migration agents, and how the work to optimise is chosen.
---
# Process

## The pipeline

<figure class="diagram">
  <picture>
    <source srcset="{{ '/assets/img/pipeline-dark.svg' | relative_url }}" media="(prefers-color-scheme: dark)">
    <img src="{{ '/assets/img/pipeline.svg' | relative_url }}" alt="OpenBSD's pinned C is ported file by file into LandingZone, which is synced commit by commit into Kernel. The same C feeds Userland, the base system, and DevTools, the toolchains, which build Userland and Kernel. Kernel, Userland and DevTools feed OS, the assembly and the release." width="643" height="547">
  </picture>
  <figcaption>The specification, the port, the redesign; the base system and the toolchains beside them; the assembly at the end.</figcaption>
</figure>

The repositories live in the [EmiBSD organisation]({{ site.repo_org }}) on GitHub:

| Repository | What it holds |
|---|---|
| [LandingZone]({{ site.repo_lz }}) | the faithful port of the OpenBSD kernel, one C file to one Rust file |
| [Kernel]({{ site.repo }}) | the redesign of that port into four crates, subsystem by subsystem |
| [Userland]({{ site.repo_userland }}) | the base system above the kernel: every program, library and configuration file placed by what it does, not by where history left it |
| [DevTools]({{ site.repo_devtools }}) | the toolchains, imported and built once: LLVM as OpenBSD ships it for the C, and a pinned stable Rust with its `std` for `aarch64-unknown-openbsd` |
| [OS]({{ site.repo_os }}) | the assembly and the releases: a manifest pins one commit of each of the three, the recipes build where they build, assemble the sets and media, boot them and tag `YEAR.MONTH`; nothing released yet |
| [Governance]({{ site.repo_governance }}) | what binds the rest: the invariants every repository obeys, the process, the architecture of the repositories, the roadmap across them, the decision log and the policies |

The forks beside them (`OpenBSD-src`, `rust`, `llvm-project`, `cargo`) are read-only mirrors of
the sources the repositories pin; nothing of EmiBSD's is committed to them.

### LandingZone, the port

[LandingZone]({{ site.repo_lz }}) (formerly EmiBSD.LZ) ports the OpenBSD kernel to Rust one C file at a time. Each Rust
file names the C file it came from and keeps its structure, so a reader can hold the two side by
side. Its job is fidelity: it boots OpenBSD's userland, and its own milestones (M0 onwards)
track which parts of the C are ported.

### Kernel, the redesign

[Kernel]({{ site.repo }}) started from LandingZone's tree on 2026-10-09 and has been rebuilding it since. The target is
four pieces:

| Crate | Path | What it holds | `unsafe` |
|---|---|---|---|
| `kernel` | `sys/kernel/` | every decision of the OS | forbidden by the compiler |
| `abi` | `sys/abi/` | OpenBSD's system-call interface, loaded as the module `abi_openbsd.ko` | forbidden by the compiler |
| `hal` | `sys/hal/` | the hardware and the runtime (locks, pools, user copies) | allowed, each site proved |
| `bsd` | `sys/` | the LandingZone tree still being replaced | inherited from LandingZone, deleted at the end |

A subsystem leaves `bsd` when it is redesigned into `kernel`, written from the C's behaviour with
LandingZone's code as the reference. What it still needs from code that has not moved goes through a
narrow, registered bridge, never a direct call.

LandingZone keeps porting after the split. Every LandingZone commit is triaged in Kernel: applied, re-implemented in
the new shape, already covered by the redesign, or not applicable, with the reason recorded.
A security fix is never skipped silently.

### Userland, the base system

[Userland]({{ site.repo_userland }}) is where the system above the kernel takes shape. Its one
decision so far is order: OpenBSD's tree grew by accretion (`bin`, `sbin`, `usr.bin`, `usr.sbin`,
`libexec`, programs side by side with no grouping); Userland's tree places every one of them by
what it does, with a catalogue that maps each OpenBSD program to exactly one place. Its shape is
settled; its content is at the start. Until it boots, the system runs OpenBSD's own userland,
built unmodified from the pinned source.

### DevTools, the toolchains

[DevTools]({{ site.repo_devtools }}) holds what compiles the rest, all of it imported, nothing
written: LLVM as OpenBSD ships it, with OpenBSD's patches, for the C; and rust-lang/rust at a
pinned stable tag, built with its own LLVM, so that `aarch64-unknown-openbsd`, a tier 3 target,
gets its standard library from a stable release's source without nightly. Built once, released
as artifacts the other repositories consume.

### OS, the assembly

[OS]({{ site.repo_os }}) builds nothing of its own. Its manifest pins one commit of Kernel,
Userland and DevTools and records the OpenBSD pin they share; its recipes fetch them, delegate
each build to its repository, assemble the install sets and the media, boot them in QEMU,
compare the installed system with a real OpenBSD and tag the release as `YEAR.MONTH`. Nothing
has been released; the first milestone is the pinned Kernel booting from a clean clone.

### Provenance

Every Rust file under `sys/` is listed in `lineage.toml` with the LandingZone files it derives from, and
its status: `inherited` (byte for byte LandingZone's), `adapted` (only its call sites changed) or
`redesigned`. Every function a LandingZone file had is accounted for: kept, renamed, split, merged or
dropped with a reason. The tooling can answer where any LandingZone or OpenBSD function went.

## The migration agent

The redesign is carried out by AI coding agents (Claude Code), each with a fixed role and a
shared rulebook that lives in the repository. One human maintainer takes the decisions: scope,
dependencies, the `unsafe` ceilings, anything userland could see. They see every plan and
approve every commit. The rules that cross repositories, and every decision that does, are
public in [Governance]({{ site.repo_governance }}), one file per decision, numbered and dated.

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
  written, the LandingZone module and the C behind it are read completely.
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
