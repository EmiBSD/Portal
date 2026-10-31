---
title: Contributing
description: How to report a bug, ask a question or propose a change to EmiBSD, the target hardware, and a short FAQ.
---
# Contributing

## Issues

Bugs, questions and proposals go to the [Kernel issue tracker]({{ site.repo }}/issues), in
English; its forms ask for what is needed to reproduce. A useful report says which commit you
built, which `just` recipe you ran, and includes the serial output from QEMU.

A difference from OpenBSD's behaviour is a bug, even a small one: the error number a system
call returns, a line a utility prints, a sysctl value. If you can, say what OpenBSD does in the
same case. A problem that is also in the faithful port can go to
[LandingZone's issues]({{ site.repo_lz }}/issues) instead.

## Security

Report a vulnerability privately, never in a public issue:
[Report a vulnerability]({{ site.repo }}/security/advisories/new) on the Kernel repository. The
policy is [SECURITY.md]({{ site.repo }}/blob/main/.github/SECURITY.md).

## Pull requests

External pull requests are not accepted for now. Every change follows a fixed process: the
provenance of each file is recorded, licence notices are kept whole, new `unsafe` is allowed
only in the `hal` crate with a soundness argument, the system-call ABI stays byte-identical,
and every merge is reviewed. If you have a fix, describe it in an issue (a diff in the issue is
fine) and it will be applied with credit. The details are in
[CONTRIBUTING.md]({{ site.repo }}/blob/main/.github/CONTRIBUTING.md), and the rules every change
follows in [CLAUDE.md]({{ site.repo }}/blob/main/CLAUDE.md) and
[`.claude/rules/`]({{ site.repo }}/tree/main/.claude/rules).

## Discussions and community

- **Discussions:** not open yet. <!-- PLACEHOLDER: link to GitHub Discussions once enabled in the repository settings. -->
- **Community channel:** not open yet. <!-- PLACEHOLDER: link to the community channel (chat or mailing list) once it exists. -->

Until then, the issue tracker is the place for questions too.

## Target hardware

| Target | Today |
|---|---|
| x86-64 (amd64) | runs in QEMU only; frozen until milestone N10, while arm64 goes first |
| Raspberry Pi 5 (arm64) | not supported yet; the arm64 kernel runs on QEMU's `virt` machine |

Neither target has booted EmiBSD on real hardware. Reports of what OpenBSD itself does on these
machines are welcome, since its behaviour is the specification.

## FAQ

<dl>
  <dt>Can I use EmiBSD?</dt>
  <dd>Not for anything real. It is pre-alpha, boots only in QEMU, and its crypto, network and storage code is unaudited.</dd>

  <dt>Is this OpenBSD?</dt>
  <dd>No. It is an independent experiment built on OpenBSD's source code, not affiliated with or endorsed by the OpenBSD project. OpenBSD's userland runs on it unmodified.</dd>

  <dt>Is there a release, an image or a package?</dt>
  <dd>No. You build it from the repository; see <a href="{{ '/docs/' | relative_url }}">Docs</a>.</dd>

  <dt>Why several repositories?</dt>
  <dd>Each holds one thing. <a href="{{ site.repo_lz }}">LandingZone</a> (formerly EmiBSD.LZ) ports OpenBSD's kernel faithfully, file by file; <a href="{{ site.repo }}">Kernel</a> redesigns what LandingZone ported, and keeping the two apart keeps the port checkable against the C. <a href="{{ site.repo_userland }}">Userland</a> is the base system above the kernel and <a href="{{ site.repo_devtools }}">DevTools</a> the toolchains that build it all; <a href="{{ site.repo_os }}">OS</a> assembles them into a system and cuts the releases. See <a href="{{ '/process/' | relative_url }}">Process</a>.</dd>

  <dt>Is AI used to write the code?</dt>
  <dd>Yes. The redesign is carried out by AI coding agents under fixed roles and written rules; one maintainer takes the decisions and approves every commit.</dd>

  <dt>Under what licence?</dt>
  <dd>New code is ISC. Files derived from OpenBSD keep their original notices (BSD, ISC and others), whole; the <a href="{{ site.repo }}/blob/main/LICENSE">LICENSE</a> file lists them.</dd>
</dl>
