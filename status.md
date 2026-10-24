---
title: Status
description: Where the EmiBSD redesign stands, subsystem by subsystem - moved into the safe kernel crate, in progress, or still in the ported LandingZone tree.
---
{%- assign s = site.data.status -%}
{%- assign hal = s.crates | where: "name", "hal" | first -%}
{%- assign bsd = s.crates | where: "name", "bsd" | first %}
# Status

**Pre-alpha.** EmiBSD boots in QEMU on arm64 and runs OpenBSD's userland, but most of the
kernel is still the 1:1 port inherited from LandingZone. amd64 builds are frozen until milestone
N10. There is no release.

The goal is a kernel with no `unsafe`: today the `kernel` and `abi` crates hold **0**, the
hardware layer `hal` holds {{ hal.unsafe }} (each with a written proof), and the ported LandingZone tree,
`bsd`, still holds {{ bsd.unsafe }}, falling as each subsystem moves out. Figures from the
[Kernel]({{ site.repo }}) repository at commit `{{ s.commit }}` ({{ s.date }}), {{ s.at }}; the
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
{%- for m in s.milestones %}
| {{ m.name }} {{ m.title }} | {{ m.scope }} | {% if m.date %}<span class="state state-done">done</span> {{ m.date | slice: 0, 10 }}{% elsif m.state == "in progress" %}<span class="state state-wip">in progress</span>{% else %}<span class="state state-todo">pending</span>{% endif %} |
{%- endfor %}

## {{ s.next.name }}, the next milestone

N5 moves the VFS and the file systems out of the LandingZone tree into `kernel::fs`. It closes
when `sys/kern/vfs_*` and the `sys/ufs/`, `sys/nfs/`, `sys/isofs/`, `sys/msdosfs/`,
`sys/ntfs/`, `sys/tmpfs/` and `sys/miscfs/` directories are gone from `bsd` (the plan counted
816 `unsafe` in 134 files there), and the full test suite passes. The plan is Kernel's
[`docs/ZERO_UNSAFE.md`]({{ site.repo }}/blob/main/docs/ZERO_UNSAFE.md) section 0.8; as in N4,
a slice may be split or renumbered when it starts, and this table follows.

| Slice | What moves | State |
|---|---|---|
{%- for sl in s.next.slices %}
| {{ sl.slice }} | {{ sl.what }} | {% if sl.state == "done" %}<span class="state state-done">done</span>{% elsif sl.state == "in progress" %}<span class="state state-wip">in progress</span>{% else %}<span class="state state-todo">pending</span>{% endif %} |
{%- endfor %}

N4, the milestone before, closed on 2026-10-24 in seventeen slices; its results, and what it
cost in speed, are in [its news entry]({{ '/news/2026/10/24/n4-met/' | relative_url }}).

## The crates today

Files and `unsafe` counts printed by `cargo xtask unsafe-report` at `{{ s.commit }}`.

| Crate | Files | `unsafe` | Note |
|---|---|---|---|
{%- for c in s.crates %}
| `{{ c.name }}`{% if c.label %} ({{ c.label }}){% endif %} | {{ c.files }} | {{ c.unsafe }} | {{ c.note }} |
{%- endfor %}
{: .numbers}

The detailed plan, with each milestone's exit criterion, is
[ROADMAP.md]({{ site.repo }}/blob/main/docs/ROADMAP.md) in the Kernel repository; the day-to-day state
is [STATUS.md]({{ site.repo }}/blob/main/docs/STATUS.md).
