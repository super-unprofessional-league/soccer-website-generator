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

    class SeasonPageGenerator < Jekyll::Generator
        safe true

        def generate(site)
            # puts site.pages
            site.data['seasons'].each do |season|
                # convert nilClass to array
                team_array = (season[1]['teams'].to_a).map{|key, team| team}

                team_hash = Hash.new

                games_pair = season[1]['games'].to_a

                # site['team_pages'] = []
                # team pages
                team_array.each do |team|
                    team_hash[team['key']] = team
                    # TODO: optimize: parse games_pair once, built team2games map
                    site.pages << TeamPage.new(site, site.source, File.join('seasons', season[0], team['key']), team, games_pair)
                end

                # game pages
                # game_hash = Hash.new{ (season[1]['games'].to_a).map{|key, game| game_hash[key] = game} }

                

                # games_hash = Hash.new
                # games_pair.map{|key, game| games_hash[key] = game}
                
                
                # puts game_array

                games_pair.each do |key, game|
                    # games_hash[key] = game

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
                # puts games_pair
                # season table page
                site.pages << SeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_array, games_pair)
            end
        end
    end




end