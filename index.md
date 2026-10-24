---
title: Home
description: EmiBSD, a port of the OpenBSD -current kernel to Rust. Pre-alpha; it runs only in QEMU.
---
<div class="home" markdown="1">

<div class="hero">
  <picture>
    <source srcset="{{ '/assets/img/ferffy-lines-white.svg' | relative_url }}" media="(prefers-color-scheme: dark)">
    <img src="{{ '/assets/img/ferffy-lines-black.svg' | relative_url }}" alt="Ferffy, the EmiBSD mascot: a spiky crab, drawn in line art" width="150" height="112">
  </picture>
  <div>
    <h1>EmiBSD <span class="badge">pre-alpha</span></h1>
    <p class="tagline">A port of the OpenBSD -current kernel to Rust.</p>
    <p class="sub">OpenBSD's own userland runs on it unmodified; inside, the kernel is being rebuilt subsystem by subsystem, with zero <code>unsafe</code> as the goal.</p>
    <p class="cta"><a class="button" href="{{ site.repo }}">View on GitHub</a> <a class="button ghost" href="{{ '/docs/' | relative_url }}">Build it</a></p>
  </div>
</div>

<div class="notice" markdown="1">
**Not for production.** EmiBSD boots only in QEMU, today on arm64 alone. Its crypto, network and
storage code is unaudited. Do not use it to protect real data or real networks.
</div>

An operating system in Rust, grown from the faithful port of the OpenBSD kernel: the system
calls and everything userland sees match OpenBSD. Milestones N0 to N4 (bootstrap, leaves,
foundations, memory, processes) are met; N5, VFS and file systems, is next.

<ul class="cards">
  <li><a href="{{ '/about/' | relative_url }}"><strong>About</strong><span>Why it exists, how it started, and what Rust brings.</span></a></li>
  <li><a href="{{ '/process/' | relative_url }}"><strong>Process</strong><span>From the 1:1 port to the redesign, and who does the work.</span></a></li>
  <li><a href="{{ '/status/' | relative_url }}"><strong>Status</strong><span>Each kernel subsystem: moved, in progress or pending.</span></a></li>
  <li><a href="{{ '/contributing/' | relative_url }}"><strong>Contributing</strong><span>Issues, target hardware, and a short FAQ.</span></a></li>
</ul>

## Latest news

<ul class="post-list">
{% for post in site.posts limit:3 %}
  <li><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time><a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>

</div>
