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

    # default SeasonPage (League table)
    class SeasonPage < Jekyll::Page
    # class SeasonPage < Jekyll::PageWithoutAFile
        def initialize(site, base, dir, season, team_array, games_pair)
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


            # team_array = (season[1]['teams'].to_a).map{|key, team| team}

            sorted = (team_array.sort_by { |team| [ -team['table']['points'], -team['table']['goals_for'] + team['table']['goals_against'], -team['table']['goals_for'] ] })
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

            # group stage

            groups = config['group_stage']

            # puts groups.count
            group_tables = Hash.new

            groups.each do |group_key, team_keys|
                # simple not points version first
                team_array = team_keys.map{|key| team_hash[key]}
                group_tables[group_key] = team_array
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

                team_array = (season[1]['teams'].to_a).map{|key, team| team}

                team_hash = Hash.new

                games_pair = season[1]['games'].to_a

                # puts games_pair

                # site['team_pages'] = []
                # team pages
                team_array.each do |team|
                    team_hash[team['key']] = team
                    # TODO: optimize: parse games_pair once, built team2games map
                    site.pages << TeamPage.new(site, site.source, File.join('seasons', season[0], team['key']), team, games_pair)
                end

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
                    site.pages << SeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_array, games_pair)
                elsif config['type'] == 'group + knockout'
                    site.pages << GroupAndKnockOutSeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_hash, games_hash, games_pair, config)
                end


                # puts games_hash
                # puts games_pair
                # season table page
                
            end
        end
    end

    # class SeasonPageGenerator < Jekyll::Generator
    #     safe true

    #     def generate(site)
    #         # puts site.pages
    #         site.data['seasons'].each do |season|
    #             # convert nilClass to array
    #             team_array = (season[1]['teams'].to_a).map{|key, team| team}

    #             team_hash = Hash.new

    #             games_pair = season[1]['games'].to_a

    #             # site['team_pages'] = []
    #             # team pages
    #             team_array.each do |team|
    #                 team_hash[team['key']] = team
    #                 # TODO: optimize: parse games_pair once, built team2games map
    #                 site.pages << TeamPage.new(site, site.source, File.join('seasons', season[0], team['key']), team, games_pair)
    #             end

    #             # game pages
    #             # game_hash = Hash.new{ (season[1]['games'].to_a).map{|key, game| game_hash[key] = game} }

                

    #             # games_hash = Hash.new
    #             # games_pair.map{|key, game| games_hash[key] = game}
                
                
    #             # puts game_array

    #             games_pair.each do |key, game|
    #                 # games_hash[key] = game

    #                 home_team = team_hash[game['home']['key']]
    #                 away_team = team_hash[game['away']['key']]

    #                 game['home']['display_name'] = home_team['display_name']
    #                 game['home']['logo'] = home_team['logo']
    #                 game['away']['display_name'] = away_team['display_name']
    #                 game['away']['logo'] = away_team['logo']
    #                 # puts home_team
    #                 site.pages << GamePage.new(site, site.source, File.join('seasons', season[0], 'games', key), game)
    #             end

    #             # puts games_hash
    #             # puts games_pair
    #             # season table page
    #             site.pages << SeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_array, games_pair)
    #         end
    #     end
    # end




end