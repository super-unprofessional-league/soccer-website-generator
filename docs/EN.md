# Super Unprofessional League Website Generator

By shrekshao狄学长

[EN](#) | [简体中文](../README.md)

[Demo](https://super-unprofessional-league.github.io/soccer-website-generator/) (in Chinese)

A Jekyll based static site generator for website of a unprofessional league.

![](tournament-page.png)

![](team-page.png)

![](game-page.png)

Features include: 
* Multiple seasons
    - League (traditional table, with data auto calculated from game data)
    - Tournament (group stage table + knockout stage bracket)
* Game
    - score
    - info: date, round, etc.
    - events
        - goal
        - penalty
        - yellow card
        - red card
        - sub
        - pictures
        - video embed code
* Player stats table
    - goal scorer (goals auto calculated from game data)
* Team page
    - Starting and sub player list
    - Formation of starting squad
    - Pictures
* Language translation support
* News post


It is suitable for college and community league since it can be hosted free on a number of place.

## Getting Started (TODO: Refine)

* install [Jekyll](https://jekyllrb.com/docs/) (More basic tutorials follow Jekyll)
* `bundle install`
* generate the site by running `bundle exec jekyll serve` during development.
* build the site by running `bundle exec jekyll build` before publish.
* init git in `_site` folder, push to the `gh_page` branch on github to host
    * github cannot automatically built since we use customized jekyll plugin.


## Add your data

All league data (matches, squad, etc.) goes under `_data` folder. All static assets (photos, images) better goes under `assets`.

### _data folder structures

* _data
    - seasons
        - 2018-2019
            - config.json (optional, default to League table style)
            - teams
                * bayern.json
                * dortmund.json
            - games
                * 2018-11-10-1.json

### Team json file example

```json
{
    "key": "dortmund",
    "display_name": "Borussia Dortmund",
    "description": "blahblahblah...",
    "logo": "bvb09.jpg",
    "table": {
        "games_played": 20,
        "wins": 15,
        "draws": 4,
        "loses": 1,
        "goals_for": 51,
        "goals_against": 20,
        "points": 49
    },
    "players": {
        "starting": [
            {
                "number": 1,
                "name": "Roman Burki",
                "img": "placeholder-player.jpg",
                "locator": "GK",
                "position": "GoalKeeper"
            }
            ,{
                "number": 28,
                "name": "Axel Witsel",
                "img": "placeholder-player.jpg",
                "locator": "CDM",
                "position": "Midfielder"
            }
            ,{
                "number": 11,
                "name": "Marco Reus",
                "img": "placeholder-player.jpg",
                "locator": "CAM",
                "position": "Forward"
            }
        ],
        "subs": [
            {
                "number": 22,
                "name": "Christian Pulisic",
                "img": "placeholder-player.jpg",
                "position": "Midfielder"
            }
            
        ]
    }
}
```

* squad position (`GK`, `CM`, etc) abbreviations are correspond to predefined positions in css (take a look to see the full list [here](https://github.com/super-unprofessional-league/super-unprofessional-league-website/blob/master/assets/css/custom-football-squad.css#L70))

![](field-locator.png)

### Game json file example

```json
{
    "date": "2018/11/10/9:30",
    "type": "round-11",
    "home": {
        "key": "dortmund",
        "score": 3,
        "events": [
            {"type": "yellow", "time": 29, "player": "Weigl"},
            {"type": "yellow", "time": 36, "player": "Akanji"},
            {"type": "off", "time": 46, "player": "Weigl"},
            {"type": "sub", "time": 46, "player": "Dahoud"},
            {"type": "penalty", "time": 49, "player": "Reus"},
            {"type": "goal", "time": 67, "player": "Reus"},
            {"type": "goal", "time": 73, "player": "Paco Alcacer"}
        ]
    },
    "away": {
        "key": "bayern",
        "score": 2,
        "events": [
            {"type": "goal", "time": 26, "player": "Lewandowski"},
            {"type": "goal", "time": 52, "player": "Lewandowski"},
            {"type": "yellow", "time": 55, "player": "Ribery"}
        ]
    }
}
```

### config.json 联赛设置

```json
{
  "display_name": "2013",
  "type": "group + knockout",
  "group_stage": {
    "A": [
      "613111",
      "610122",
      "610121",
      "610111"
    ],
    "B": [
      "611111",
      "613121",
      "610113",
      "610112"
    ]
  },
  "knockout_stage": [
    [
      ["610131", "610111", "2013-10-21-1"],
      
      ["613111", "610112", "2013-10-20-1"],

      ["613131", "611131", ""],

      ["610132", "611111", "2013-10-15-1"]
    ],
    [
      ["610111", "613111", "2013-11-14-1"],
      
      ["611131", "610132", "2013-11-15-1"]
    ],
    [
      ["613111","611131", "2013-11-17-1"]
    ]
  ],
  "winner": "613111",
  "rules": "*hahahah\n*hahha"
}
```

* Season defaults to League type if this file doesn't exist
* `type`
    - `league`
    - `group + knockout`
* if `type = "group + knockout"`
    * `group_stage` is `group name` => `team file name (without ext)`
    * `knockout_stage` element length is power of 2，... 16, 8, 4, 2, 1
    * `["home team file name (without ext)", "away team file name (without ext)", "game file name (without ext)"]`