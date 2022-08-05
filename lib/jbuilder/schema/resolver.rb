require "jbuilder/schema/parser"
require "jbuilder/schema/template"
require "jbuilder/dependency_tracker"

module JbuilderSchema
  class Resolver < ::ActionView::FileSystemResolver
    # include JbuilderSchema::Formatter

    def initialize(path)
      super("app/views/#{path}")
    end

    def find_all(name, prefix = nil, partial = false)
      _find_all(name, prefix, partial)
    end

    private

    def _find_all(name, prefix, partial)
      path = ActionView::TemplatePath.build(name, prefix, partial)
      templates_from_path(path).first
    end

    def templates_from_path(path)
      if path.name.include?(".")
        return []
      end

      # Instead of checking for every possible path, as our other globs would
      # do, scan the directory for files with the right prefix.
      paths = template_glob("#{escape_entry(path.to_s)}*")

      paths.map do |path|
        build_template(path)
      end
    end

    def build_template(template)
      source = source_for_template(template)
      _parse_source(source)

      # JbuilderSchema::Template.new

      # @article = Article.first
      #

      #{source}

      # puts "!!!>>>PARSED SOURCE #{_parse_source(source)}"
      #
      # json

      # puts "SSS>>SSS> #{eval(source.to_s)}"
      #
      # JbuilderSchema::Template.new do |json, *|
      #   eval(_parse_source(source))
      # end
    end

    def _parse_source(source)
      JbuilderSchema::Parser.new(source).parse!
    end

    # def _parse_source(source)
    #   Zeitwerk::Loader.eager_load_all if defined?(Zeitwerk::Loader)
    #
    #   lines = source.to_s
    #                 .split(/\n+|\r+/)
    #                 .reject(&:empty?)
    #                 .reject { |l| l.start_with?('#') }
    #                 .map { |l| l.split('#').first }
    #
    #   lines.map do |line|
    #
    #     puts ">>>LINE: #{line}"
    #
    #     line.split[1..-1].each do |element|
    #       puts ">>>DANGER: #{element}"
    #
    #       begin
    #         eval(element)
    #       rescue NoMethodError
    #         data = _find_data(element)
    #         line.gsub!(element, data.to_s)
    #       end
    #     end
    #   end
    #
    #   lines.join("\n")
    # end
    #
    # def _find_data(string)
    #   variable, method = string.split('.')
    #   type = ObjectSpace.each_object(Class).select { |c| c.name == variable.gsub('@', '').classify }.first.columns_hash[method].type
    #   1
    # end
  end
end
