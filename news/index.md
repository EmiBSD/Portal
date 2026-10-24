---
title: News
description: The EmiBSD devlog - milestones, decisions and what changed.
---
# News

The devlog: milestones met, decisions taken, and what changed. Also available as a
[feed]({{ '/news/feed.xml' | relative_url }}).

## Recent updates

<ul class="post-list">
{% for item in site.data.news %}
  <li><time datetime="{{ item.date }}T00:00:00Z">{{ item.date }}</time><a href="{{ item.url | relative_url }}">{{ item.title }}</a></li>
{% endfor %}
</ul>

## Milestones

| Milestone | Title | Completed | Repository |
|-----------|-------|-----------|------------|
{% for milestone in site.data.milestones %}
| [{{ milestone.name }}]({{ site.repo }}/releases/tag/{{ milestone.slug }}) | {{ milestone.title }} | {{ milestone.completed }} | {{ milestone.repo }} |
{% endfor %}
