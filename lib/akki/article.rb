require 'haml'

module Akki
  class Article
    attr_accessor :title, :slug, :date, :content

    def initialize(title, date, content, slug)
      @title   = title
      @date    = date
      @content = content
      @slug = slug
    end

    def render
      Haml::Engine.new(content).render
    end

    def path
      date.strftime("/%Y/%m/%d/") + slug
    end

    class << self
      def all
        unless defined? @articles
          @articles = get_all_articles
        end
        @articles
      end

      def find year, month, day, slug
        article = all.select { |article|
          article.date.year  == year  &&
          article.date.month == month &&
          article.date.day   == day   &&
          article.slug       == slug
        }.first
      end

      private

      def get_all_articles
        Dir.glob("articles/*").map { |path|
          get_article path
        }.sort { |a, b| a.date <=> b.date }.reverse
      end

      def get_article path
        parts = File.read(path).split("\n\n", 2)
        yaml = YAML.load(parts[0])
        content = parts[1]
        title = yaml['title']
        date  = Date.strptime(yaml['date'], '%Y/%m/%d')
        slug = File.basename(path).split("-", 4).last.gsub(".txt", "")
        Article.new(title, date, content, slug)
      end
    end
  end
end
