require 'json'

module League

    class GoalScorerPage < Jekyll::Page
        def initialize(site, base, dir, season_name, rank_table, team_hash)
            @site = site
            @base = base
            @dir = dir
            @name = 'goal_scorers.html'

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'goal_scorers.html')

            self.data['rank_table'] = rank_table
            self.data['team_hash'] = team_hash
            self.data['display_name'] = season_name
        end
    end

    class TeamPage < Jekyll::Page
        def initialize(site, base, dir, team_key, team, season_key, season)
            @site = site
            @base = base
            @dir = dir
            @name = 'index.html'

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'team.html')
            

            self.data['team_key'] = team_key
            self.data['team'] = team
            self.data['season_key'] = season_key
            self.data['season'] = season
        end
    end

    class GamePage < Jekyll::Page
        def initialize(site, base, dir, game)
            @site = site
            @base = base
            @dir = dir
            @name = 'index.html'

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'game.html')
            

            self.data['game'] = game
            # self.data['home_team'] = home_team
            # self.data['away_team'] = away_team

            
        end
    end

    def self.calculate_table (team_hash, games_pair, entry)
        # Iterate games to calculate data

        # clear data 
        for team in team_hash
            team[1][entry] = {
                'games_played' => 0,
                'wins' => 0,
                'draws' => 0,
                'loses' => 0,
                'goals_for' => 0,
                'goals_against' => 0,
                'goals_diff' => 0,
                'points' => 0
            }
        end

        for p in games_pair
            key = p[0]
            game = p[1]

            t0 = team_hash[game['home']['key']][entry]
            t0['games_played'] += 1;
            t0['goals_for'] += game['home']['score'];
            t0['goals_against'] += game['away']['score'];

            t1 = team_hash[game['away']['key']][entry]
            t1['games_played'] += 1;
            t1['goals_for'] += game['away']['score'];
            t1['goals_against'] += game['home']['score'];
            
            if game['home']['score'] > game['away']['score']
                t0['wins'] += 1;
                t1['loses'] += 1;
            elsif game['home']['score'] < game['away']['score']
                t1['wins'] += 1;
                t0['loses'] += 1;
            else
                t0['draws'] += 1;
                t1['draws'] += 1;
            end
        end

        # post process
        for team in team_hash
            t = team[1][entry]
            t['goals_diff'] = t['goals_for'] - t['goals_against']
            t['points'] = t['wins'] * 3 + t['draws']

            t['avg_gf'] = t['games_played'] == 0 ? 0.0 : t['goals_for'].fdiv(t['games_played'])
            t['avg_ga'] = t['games_played'] == 0 ? 0.0 : t['goals_against'].fdiv(t['games_played'])

            t['avg_gf'] = sprintf("%0.1f", t['avg_gf'])
            t['avg_ga'] = sprintf("%0.1f", t['avg_ga'])
        end
    end

    # default SeasonPage (League table)
    class LeagueSeasonPage < Jekyll::Page
    # class LeagueSeasonPage < Jekyll::PageWithoutAFile
        def initialize(site, base, dir, season, team_hash, games_pair, config, season_name)
            @site = site
            @base = base
            @dir = dir
            # @name = "#{season[0]}.html"
            @name = "index.html"
            # @layout = 'season.html'
            # @path = if site.in_theme_dir(base) == base # we're in a theme
            #     site.in_theme_dir(base, dir, name)
            #   else
            #     site.in_source_dir(base, dir, name)
            #   end

            # puts @path

            self.process(@name)
            
            
            # self.data = season[1]
            # puts base
            self.read_yaml(File.join(base, "_layouts"), "season.html")

            # self.data = {}
            
            # if config != nil and config['display_name'] != nil
            #     self.data['display_name'] = config['display_name']
            # else
            #     self.data['display_name'] = season
            # end
            # self.data["title"] = self.data['display_name']

            self.data['display_name'] = season_name
            self.data["title"] = season_name
            self.data['winner'] = config['winner'] ? team_hash[config['winner']] : nil
            

            # League.calculate_table(team_hash, games_pair, 'table')
            team_tables = team_hash.map{ |key, value| value }

            # team_array = (season[1]['teams'].to_a).map{|key, team| team}

            sorted = (team_tables.sort_by { |team| [ -team['table']['points'], -team['table']['goals_diff'], -team['table']['goals_for'], team['table']['goals_against'], team['table']['games_played'] ] })
            # sorted = (team_array.sort_by { |team| [ -team['table']['points'], -team['table']['goals_for'] + team['table']['goals_against'], -team['table']['goals_for'] ] })
            # puts sorted

            self.data['table'] = sorted

            self.data['games_pair'] = games_pair

        end
    end

    # group + knockout for jxcup
    class GroupAndKnockOutSeasonPage < Jekyll::Page
        def initialize(site, base, dir, season, team_hash, games_hash, games_pair, config, season_name)
            @site = site
            @base = base
            @dir = dir
            @name = "index.html"
            self.process(@name)
            self.read_yaml(File.join(base, "_layouts"), "season_group_knockout.html")
            # if self.data['display_name'] != nil
            #     self.data['display_name'] = config['display_name']
            # else
            #     self.data['display_name'] = season
            # end
            # self.data["title"] = self.data['display_name']
            self.data['display_name'] = season_name
            self.data["title"] = season_name

            knockout_stage = config['knockout_stage']
            # puts knockout_stage
            
            if config['display_name'] != nil
                self.data['display_name'] = config['display_name']
            end

            # knock out stage

            # make it in correct order
            # self.data['knockout_teams']
            knockout_array = Array.new(knockout_stage.length)

            # puts knockout_stage.length

            for i in 0..(knockout_stage.length-1)
                round = knockout_stage[i]
                round_array = Array.new(round.length)

                for j in 0..(round.length-1)
                    game = round[j]
                    game_array = Array.new(3)
                    
                    # there's team info in game
                    # but we still write team info
                    # because we display versus before game happens
                    game_array[0] = team_hash[game[0]]
                    game_array[1] = team_hash[game[1]]
                    game_array[2] = [game[2], games_hash[game[2]]]

                    round_array[j] = game_array
                end

                knockout_array[i] = round_array

                # puts knockout_array[i]
                # puts team_hash[round[0]]
                # puts team_hash['613111']
            end

            # puts knockout_array

            self.data['knockout_array'] = knockout_array
            self.data['winner'] = config['winner'] ? team_hash[config['winner']] : nil


            # group stage

            groups = config['group_stage']

            if groups != nil

                ##############################################

                # Iterate games to calculate data
                group_games_pair = games_pair.select{|key, game| game['type'].include? 'group'}
                League.calculate_table(team_hash, group_games_pair,'table')

                ##############################################


                # puts groups.count
                group_tables = Hash.new
                group_games = Hash.new

                groups.each do |group_key, team_keys|
                    # simple not points version first
                    team_array = team_keys.map{|key| team_hash[key]}
                    team_keys_set = team_keys.to_set
                    sorted = (team_array.sort_by { |team| [ -team['table']['points'], -team['table']['goals_diff'], -team['table']['goals_for'], team['table']['goals_against'], team['table']['games_played'] ] })
                    group_tables[group_key] = sorted

                    # puts team_keys_set
                    cur_group_games_pair = group_games_pair.select{|key, game| team_keys_set.include?(game['home']['key'])}

                    group_games[group_key] = cur_group_games_pair
                end

                self.data['group_tables'] = group_tables
                self.data['group_games'] = group_games

            end



            # self.data['games_pair'] = games_pair
            self.data['rules'] = config['rules']

        end
    end

    class SeasonPageGenerator < Jekyll::Generator
        safe true

        def generate(site)
            # puts site.pages
            site.data['seasons'].each do |season|
                # convert nilClass to array

                team_hash = season[1]['teams']
                team_hash.each do |key, team|
                    team['games'] = Array.new
                    team['key'] = key

                    team['player_hash'] = Hash.new
                    if team['players'] != nil
                        
                        starting = team['players']['starting']
                        if starting != nil
                            starting.each do |p|
                                p['goals'] = 0
                                p['penalty'] = 0
                                team['player_hash'][p['name']] = p
                            end
                        end

                        subs = team['players']['subs']
                        if subs != nil
                            subs.each do |p|
                                p['goals'] = 0
                                p['penalty'] = 0
                                team['player_hash'][p['name']] = p
                            end
                        end
                    end

                    # team['players']['starting'].each{|p| puts p}
                end
                # team_array = (team_hash.to_a).map{|key, team| team}

                

                games_pair = season[1]['games'].to_a

                # puts games_pair

                games_hash = Hash.new

                
                # generate each game page
                games_pair.each do |p|
                    key = p[0]
                    game = p[1]
                    games_hash[key] = game
                    # puts key
                    # puts game

                    home_team = team_hash[game['home']['key']]
                    away_team = team_hash[game['away']['key']]

                    home_team['games'] << p
                    away_team['games'] << p

                    game['home']['display_name'] = home_team['display_name']
                    game['home']['logo'] = home_team['logo']
                    game['away']['display_name'] = away_team['display_name']
                    game['away']['logo'] = away_team['logo']

                    game['home']['events'].each do |e|
                        if e['type'] == 'goal' or e['type'] == 'penalty'
                            player = home_team['player_hash'][e['player']]
                            if player == nil
                                # puts e['player']
                                home_team['player_hash'][e['player']] = {'name' => e['player'], 'goals' => 0, 'penalty' => 0}
                                player = home_team['player_hash'][e['player']]
                            end
                            
                            player['goals'] += 1
                            if e['type'] == 'penalty'
                                player['penalty'] += 1
                            end
                        end
                    end

                    game['away']['events'].each do |e|
                        if e['type'] == 'goal' or e['type'] == 'penalty'
                            player = away_team['player_hash'][e['player']]
                            if player == nil
                                # puts e['player']
                                away_team['player_hash'][e['player']] = {'name' => e['player'], 'goals' => 0, 'penalty' => 0}
                                player = away_team['player_hash'][e['player']]
                            end

                            player['goals'] += 1
                            if e['type'] == 'penalty'
                                player['penalty'] += 1
                            end
                        end
                    end

                    site.pages << GamePage.new(site, site.source, File.join('seasons', season[0], 'games', key), game)
                end


                goal_scorers = Array.new

                # include all games (groups and knockout for tournament)
                League.calculate_table(team_hash, games_pair, 'stats')

                config = season[1]['config']
                season_name = season[0]
                if config != nil and config['display_name'] != nil
                    season_name = config['display_name']
                end

                stats_is_table = false
                if config == nil or config['type'] == 'league'
                    stats_is_table = true
                end


                team_hash.each do |key, team|

                    team['player_hash'].each do |pk, p|
                        if p['goals'] > 0
                            p['teamkey'] = key
                            goal_scorers << p
                        end
                    end

                    if stats_is_table
                        team['table'] = team['stats']
                    end

                    site.pages << TeamPage.new(site, site.source, File.join('seasons', season[0], key), key, team, season[0], season[1])
                end

                sorted_goal_scorers = (goal_scorers.sort_by { |p| [ -p['goals'], p['penalty'] ] })
                

                # puts games_hash

                


                # puts config
                if config == nil or config['type'] == 'league'
                    site.pages << LeagueSeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_hash, games_pair, config, season_name)
                elsif config['type'] == 'group + knockout'
                    site.pages << GroupAndKnockOutSeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_hash, games_hash, games_pair, config, season_name)
                end

                
                site.pages << GoalScorerPage.new(site, site.source, File.join('seasons', season[0]), season_name, sorted_goal_scorers, team_hash)


                # puts games_hash
                # puts games_pair
                # season table page
                
            end
        end
    end

end