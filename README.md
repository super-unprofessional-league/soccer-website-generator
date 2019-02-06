# Super Unprofessional League Website Generator

By shrekshao狄学长

[Demo](https://super-unprofessional-league.github.io/super-unprofessional-league-website/) (in Chinese)

[Squad Page Demo](https://iesoccerleagues.github.io/seasons/2018-fall-B/goalrush/) (in English)

A Jekyll based static site generator for website of a unprofessional league. Features include: 
* Multiple seasons
* League Table
* Game
    - score
    - info: date, round, etc.
    - events
        - goal
        - penalty
        - yellow card
        - red card
        - sub
* Team page
    - Starting and sub player list
    - Formation of starting squad
* News post

It is suitable for college and community league since it can be hosted free on a number of place.

## Getting Started (TODO: Refine)

* install [Jekyll](https://jekyllrb.com/docs/) (More basic tutorials follow Jekyll)
* generate the site by running `bundle exec jekyll serve`
* init git in `_site` folder, push to the `gh_page` branch on github to host
    * github cannot automatically built since we use customized jekyll plugin.


## Add your data

All league data (matches, squad, etc.) goes under `_data` folder. All static assets (photos, images) better goes under `assets`.

### _data folder structures

* _data
    - seasons
        - 2018-2019
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
                "position": "GoalKeeper",
                "played": 25,
                "goals": 0
            }
            ,{
                "number": 28,
                "name": "Axel Witsel",
                "img": "placeholder-player.jpg",
                "position": "Midfielder",
                "played": 28,
                "goals": 5
            }
            ,{
                "number": 11,
                "name": "Marco Reus",
                "img": "placeholder-player.jpg",
                "position": "Forward",
                "played": 27,
                "goals": 13
            }
        ],
        "subs": [
            {
                "number": 22,
                "name": "Christian Pulisic",
                "img": "placeholder-player.jpg",
                "position": "Midfielder",
                "played": 21,
                "goals": 3
            }
            
        ]
    },
    "squad": {
        "GK": 1,
        "CDM": 28,
        "CF": 11
    }
}
```

* `key` has to match the file name (I know it's stupid but I haven't fixed it)
* squad position (`GK`, `CM`, etc) abbreviations are correspond to predefined positions in css (take a look to see the full list)
* player data is not hooked up with event in game data yet.

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

