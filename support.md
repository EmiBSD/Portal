---
title: Support
description: How to support EmiBSD - sponsor the project on GitHub, what the money pays for, and what each tier gets.
---
# Support EmiBSD

EmiBSD is a hobby project: one maintainer, in the open, no company behind it. The work is done by
AI coding agents under written rules, and the maintainer reviews and approves every commit.
That method is what lets a single person carry a whole kernel into Rust, and it is also the
project's main running cost: the agents, the cloud they run in, and the machines the kernel is
tested on.

Sponsoring pays for that directly. Every sponsorship goes through
[GitHub Sponsors](https://github.com/sponsors/EmiBSD); GitHub takes no fee on sponsorships from
personal accounts.

<p><a class="button" href="https://github.com/sponsors/EmiBSD">Sponsor EmiBSD on GitHub</a></p>

## What the money pays for

| Cost | What it buys |
|---|---|
| AI coding agents | the migration and redesign work itself: a month of agent time moves roughly one kernel subsystem (see [Status]({{ '/status/' | relative_url }})) |
| Cloud and CI | builds, the host test suite, and QEMU boots on every change |
| Hardware | the boards and machines EmiBSD will boot on after QEMU: Raspberry Pi 4, an amd64 desktop |
| Domain and site | `emibsd.org` and this site |

The maintainer's own time is not paid by sponsorships.

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
- **Hardware.** If you have a Raspberry Pi 4 or an amd64 machine you can spare, or can run
  OpenBSD on one and report what it does, say so in an issue.
- **Tell someone.** A link from a blog, a talk, or a thread in the Rust or BSD communities is
  worth more to a young project than most donations.
