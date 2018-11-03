---
layout: page
title: 积分榜
permalink: /tables/
---

{% for season in site.data.seasons %}
## {{ season[0] }}
{% endfor %}

{% capture team %}
 {% for team in site.data.seasons["2013"].teams %}
   {{ team | first }}
 {% endfor %}
{% endcapture %}

{{ team_array }}


{{ site.data.seasons["2013"].teams }}

| 队名 | 比赛 | 胜 | 平 | 负 | 进球 | 失球 | 积分 |
|---------------|------------|
{% for team in site.data.seasons["2013"].teams 
%}| {{ team[1].team.name }} | {{ team[1].team.table.games_played }} | {{ team[1].team.table.wins }} | {{ team[1].team.table.draws }} | {{ team[1].team.table.loses }} | {{ team[1].team.table.goals_for }} | {{ team[1].team.table.goals_against }} | {{ team[1].team.table.points }} |
{% endfor %}
