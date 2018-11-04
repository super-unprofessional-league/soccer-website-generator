module League

    # class TeamPage < Jekyll::Page
    #     def initialize(site, base, dir, team)
    #         @site = site
    #         @base = base
    #         @dir = dir
    #         @name = 'index.html'

    #         self.process(@name)
    #         self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
    #         self.data['category'] = category

    #         category_title_prefix = site.config['category_title_prefix'] || 'Category: '
    #         self.data['title'] = "#{category_title_prefix}#{category}"
    #     end
    # end

    class SeasonPage < Jekyll::Page
    # class SeasonPage < Jekyll::PageWithoutAFile
        def initialize(site, base, dir, season)
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
            puts base
            self.read_yaml(File.join(base, '_layouts'), 'season.html')

            # self.data = {}
            self.data['title'] = season[0]
            self.data['table'] = season[1]['table']

            # puts self.data['table']
            # puts dir
        end
    end

    class SeasonPageGenerator < Jekyll::Generator
        safe true

        def generate(site)
            # puts site.pages
            site.data['seasons'].each do |season|
                # puts season[1]
                site.pages << SeasonPage.new(site, site.source, File.join('seasons', season[0]), season)
            end

            # if site.layouts.key? 'category_index'
            #     dir = site.config['team_dir'] || 'team'
            #     site.categories.each_key do |category|
            #     site.pages << TeamPage.new(site, site.source, File.join(dir, category), category)
            #     end
            # end
        end
    end




end