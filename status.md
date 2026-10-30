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
| {{ m.name }} {{ m.title }} | {{ m.scope }} | {% if m.date %}<span class="state state-done">done</span> {{ m.date | slice: 0, 10 }}{% elsif m.state %}<span class="state state-wip">{{ m.state }}</span>{% else %}<span class="state state-todo">pending</span>{% endif %} |
{%- endfor %}

## {{ s.next.name }}, the milestone in progress

N5 moves the VFS and the file systems out of the LandingZone tree into `kernel::fs`: the buffer
cache, the vnode and mount layer, name lookup, the VFS system calls, then the file systems one
by one. Two leave its scope (the maintainer's decisions of 2026-10-28): nfs is written over
sockets and mbufs, so it moves with the network stack at N6; ntfs is built on amd64 only, so it
waits for N10. Both stay in the LandingZone tree meanwhile, adapted to the kernel's VFS traits
as they land. N5 closes when those
directories are gone from `bsd` (the plan counts 656 `unsafe` in 126 files leaving), 65 more
system calls are handled natively, and the full test suite passes.

The slices below are N5's plan of 2026-10-28; Kernel's docs take them in at N5's close. As in
N4, a slice may be split or renumbered when it starts, and this table follows.

| Slice | What moves | State |
|---|---|---|
{%- for sl in s.next.slices %}
| {{ sl.slice }} | {{ sl.what }} | {% if sl.state == "done" %}<span class="state state-done">done</span>{% elsif sl.state == "in progress" %}<span class="state state-wip">in progress</span>{% else %}<span class="state state-todo">pending</span>{% endif %} |
{%- endfor %}

One slice of N12, the performance milestone, was brought forward and run beside N5 (the
maintainer's exception of 2026-10-29). N12.1 made the 13 walks over a process's memory map step
from one entry to the next as the C does, instead of looking each next entry up again: on the
host, with 1,024 entries in the map, mprotect(2) takes 62 % less time, madvise(2) 80 %,
minherit(2) 66 % and mlock(2) 36 %; the other operations measured did not change. The rest of
N12 waits for its turn.

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
