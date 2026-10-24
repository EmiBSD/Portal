---
title: News
description: The EmiBSD devlog - milestones, decisions and what changed.
---
# News

The devlog: milestones met, decisions taken, and what changed. Also available as a
[feed]({{ '/news/feed.xml' | relative_url }}).

<ul class="post-list">
{% for post in site.posts %}
  <li><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time><a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
