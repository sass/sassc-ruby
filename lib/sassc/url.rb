# frozen_string_literal: true

module SassC
  module URL
    PARSER = URI::Parser.new({ RESERVED: ';/?:@&=+$,' })

    private_constant :PARSER

    module_function

    def parse(str)
      PARSER.parse(str)
    end

    def escape(str)
      PARSER.escape(str)
    end

    def unescape(str)
      PARSER.unescape(str)
    end

    def file_url_to_path(url)
      return if url.nil?

      path = unescape(parse(url).path)
      path = path[1..] if Gem.win_platform? && path[0].chr == '/' && path[1].chr =~ /[a-z]/i && path[2].chr == ':'
      path
    end

    def path_to_file_url(path)
      return if path.nil?

      path = "/#{path}" unless path.start_with?('/')
      URI::File.build([nil, escape(path)]).to_s
    end
  end

  private_constant :URL
end
