---
layout: page
title: 积分榜
permalink: /tables/
---

{% for season in site.data.seasons %}
## {{ season[0] }}
{% endfor %}

{% assign sorted = site.data.seasons["2013"].table | sort: "points" | reverse %}

| 队名 | 比赛 | 胜 | 平 | 负 | 进球 | 失球 | 净胜 | 积分 |
|---------------|------------|
{% for team in sorted
%}| {{ team.name }} | {{ team.games_played }} | {{ team.wins }} | {{ team.draws }} | {{ team.loses }} | {{ team.goals_for }} | {{ team.goals_against }} | {{ team.goals_for | minus: team.goals_against }} | {{ team.points }} |
{% endfor %}
