---
title: Support
description: How to support EmiBSD - sponsor the project on GitHub, what the money pays for, and what each tier gets.
---
# Support EmiBSD

EmiBSD is a hobby project: one maintainer, in the open, no company behind it. The code is
written by AI coding agents under written rules; the maintainer designs each milestone, reviews
and approves every commit, and audits what the agents produce.

Sponsorship pays for three things, in this order: the hardware EmiBSD has to boot on after QEMU,
the infrastructure that verifies every change, and the maintainer's engineering and review
time. Every sponsorship goes through [GitHub Sponsors](https://github.com/sponsors/EmiBSD);
GitHub takes no fee on sponsorships from personal accounts.

<p><a class="button" href="https://github.com/sponsors/EmiBSD">Sponsor EmiBSD on GitHub</a></p>

## What the money pays for

### 1. Hardware: a first goal of about US$2,800

Today EmiBSD boots only in QEMU. The first goal is the machines it has to boot on next, two
arm64 boards and two amd64 mini PCs:

| Machine | Estimate | Why |
|---|---|---|
| [Raspberry Pi 5, 8 GB](https://www.raspberrypi.com/products/raspberry-pi-5/), with power supply, microSD card and serial cable | $300 | arm64 (Broadcom BCM2712): the first real board; OpenBSD 8.0 supports it with a serial console |
| [Radxa Orion O6, 16 GB](https://radxa.com/products/orion/o6/) | $525 | arm64 (Cix CD8180): twelve cores, for the multiprocessor code on real hardware |
| [ASUS ExpertCenter PN54, Ryzen AI 7 350, 16 GB, 1 TB](https://www.asus.com/displays-desktops/mini-pcs/pn-series/asus-expertcenter-pn54/) | $1,200 | amd64 (AMD): the amd64 port, from milestone N10 |
| [ASUS NUC 14 Pro, 16 GB, 1 TB](https://www.asus.com/displays-desktops/nucs/nuc-mini-pcs/asus-nuc-14-pro/) | $800 | amd64 (Intel): the other half of amd64's devices |
{: .numbers}

Estimates in US dollars as of October 2026: the Raspberry Pi 5 and the NUC at the prices of the
maintainer's local shops, the other two imported, with shipping, duties and taxes (about half
again the US price). Memory prices rose during 2026, so they will move. The links go to each
maker's page for the model. Only machines that OpenBSD 8.0 supports are listed: OpenBSD's
drivers are EmiBSD's specification, so a board OpenBSD does not run on cannot run EmiBSD either.

Raised so far: nothing yet. This page will show the progress.

### 2. Verification

The machines and services that build EmiBSD, run its host test suite and its scripted QEMU
boots, and run a real OpenBSD beside it for the comparison every milestone has to pass.

### 3. The maintainer's time

The engineering and the review: designing each milestone, reviewing and approving every
commit, auditing the `unsafe` that remains, and comparing EmiBSD with OpenBSD where they differ.

### Also

| Cost | What it buys |
|---|---|
| IT infrastructure | the development tools and cloud services the work runs on |
| Domain and site | `emibsd.org` and this site |

## Tiers

| Monthly | What you get |
|---|---|
| **$5** | our thanks, and your name in the `SPONSORS` file of the Kernel repository |
| **$25** | the above, and your name on this page |
| **$100** | the above, and a mention in the monthly news post, with a link |

## Sponsors

Nobody yet. The first names will appear here.

## Other ways to help

- **Use it and report.** Boot it in QEMU, compare with OpenBSD, file what differs. See
  [Contributing]({{ '/contributing/' | relative_url }}).
- **Hardware.** If you can spare one of the machines above, or another that OpenBSD supports,
  or can run OpenBSD on one and report what it does, say so in an issue.
- **Tell someone.** A link from a blog, a talk, or a thread in the Rust or BSD communities is
  worth more to a young project than most donations.
