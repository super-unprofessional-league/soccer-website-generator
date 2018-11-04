require 'json'

module League

    class TeamPage < Jekyll::Page
        def initialize(site, base, dir, team)
            @site = site
            @base = base
            @dir = dir
            @name = 'index.html'

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'team.html')
            
            self.data['team'] = team
        end
    end

    class SeasonPage < Jekyll::Page
    # class SeasonPage < Jekyll::PageWithoutAFile
        def initialize(site, base, dir, season, team_array)
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

            sorted = (team_array.sort_by { |team| -team['table']['points'] }).map {|team| team}
            # puts sorted

            self.data['table'] = sorted

        end
    end

    class SeasonPageGenerator < Jekyll::Generator
        safe true

        def generate(site)
            # puts site.pages
            site.data['seasons'].each do |season|
                # convert nilClass to array
                team_array = (season[1]['teams'].to_a).map{|key, team| team}

                # site['team_pages'] = []
                # team pages
                team_array.each do |team|
                    site.pages << TeamPage.new(site, site.source, File.join('seasons', season[0], team['key']), team)
                end

                # season table page
                site.pages << SeasonPage.new(site, site.source, File.join('seasons', season[0]), season[0], team_array)
            end
        end
    end




end