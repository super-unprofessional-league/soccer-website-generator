require 'json'

module League

    class TeamPage < Jekyll::Page
        def initialize(site, base, dir, team, games_pair)
            @site = site
            @base = base
            @dir = dir
            @name = 'index.html'

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'team.html')
            
            self.data['team'] = team
            self.data['games_pair'] = games_pair
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

    def self.calculate_table (team_hash, games_pair)
        # Iterate games to calculate data

        # clear data 
        for team in team_hash
            # if team['table'] == nil
            #     team['table'] = Hash.new
            # end
            team[1]['table'] = {
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

            t0 = team_hash[game['home']['key']]['table']
            t0['games_played'] += 1;
            t0['goals_for'] += game['home']['score'];
            t0['goals_against'] += game['away']['score'];

            t1 = team_hash[game['away']['key']]['table']
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
            t = team[1]['table']
            t['goals_diff'] = t['goals_for'] - t['goals_against']
            t['points'] = t['wins'] * 3 + t['draws']
        end
    end

    # default SeasonPage (League table)
    class SeasonPage < Jekyll::Page
    # class SeasonPage < Jekyll::PageWithoutAFile
        def initialize(site, base, dir, season, team_hash, games_pair)
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
            self.data["title"] = season

            League.calculate_table(team_hash, games_pair)
            # Object.send(:calculate_table, team_hash, games_pair)
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
        def initialize(site, base, dir, season, team_hash, games_hash, games_pair, config)
            @site = site
            @base = base
            @dir = dir
            @name = "index.html"
            self.process(@name)
            self.read_yaml(File.join(base, "_layouts"), "season_group_knockout.html")
            self.data["title"] = season
            # self.data["title"] = config['display_name']

            knockout_stage = config['knockout_stage']
            # puts knockout_stage
            
            self.data['display_name'] = config['display_name']


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


            ##############################################

            # Iterate games to calculate data
            group_games_pair = games_pair.select{|key, game| game['type'].include? 'group'}
            League.calculate_table(team_hash, group_games_pair)

            ##############################################

            # group stage

            groups = config['group_stage']

            # puts groups.count
            group_tables = Hash.new

            groups.each do |group_key, team_keys|
                # simple not points version first
                team_array = team_keys.map{|key| team_hash[key]}
                sorted = (team_array.sort_by { |team| [ -team['table']['points'], -team['table']['goals_diff'], -team['table']['goals_for'], team['table']['goals_against'], team['table']['games_played'] ] })
                group_tables[group_key] = sorted
            end

            self.data['group_tables'] = group_tables



            self.data['games_pair'] = games_pair

        end
    end

    class SeasonPageGenerator < Jekyll::Generator
        safe true

        def generate(site)
            # puts site.pages
            site.data['seasons'].each do |season|
                # convert nilClass to array

                team_hash = season[1]['teams']
                # team_array = (team_hash.to_a).map{|key, team| team}

                

                games_pair = season[1]['games'].to_a

                # puts games_pair

                team_hash.each do |key, team|
                    site.pages << TeamPage.new(site, site.source, File.join('seasons', season[0], key), team, games_pair)
                end
                # team_array.each do |team|
                #     # TODO: optimize??: parse games_pair once, built team2games map (more mem)
                #     site.pages << TeamPage.new(site, site.source, File.join('seasons', season[0], team['key']), team, games_pair)
                # end

                games_hash = Hash.new

                
                # generate each game page
                games_pair.each do |key, game|
                    games_hash[key] = game
                    # puts key

                    home_team = team_hash[game['home']['key']]
                    away_team = team_hash[game['away']['key']]

                    game['home']['display_name'] = home_team['display_name']
                    game['home']['logo'] = home_team['logo']
                    game['away']['display_name'] = away_team['display_name']
                    game['away']['logo'] = away_team['logo']
                    # puts home_team
                    site.pages << GamePage.new(site, site.source, File.join('seasons', season[0], 'games', key), game)
                end

                # puts games_hash

                config = season[1]['config']
                # puts config
                if config == nil or config['type'] == 'league'
                    site.pages << SeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_hash, games_pair)
                elsif config['type'] == 'group + knockout'
                    site.pages << GroupAndKnockOutSeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_hash, games_hash, games_pair, config)
                end


                # puts games_hash
                # puts games_pair
                # season table page
                
            end
        end
    end

end