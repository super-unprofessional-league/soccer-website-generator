---
layout: post
---

{% if page.season_key != nil and page.game_key != nil %}
{% assign gk = page.game_key %}
{% assign g = site.data.seasons[page.season_key].games[gk] %}
{% include game_lines.md game_key=gk game=g season_key=page.season_key %}
{% endif %}

<br/>
{{content}}