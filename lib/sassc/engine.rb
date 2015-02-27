module SassC
  class Engine
    def initialize(template, options = {})
      #@options = self.class.normalize_options(options)
      @template = template
    end

    def render
      return _to_tree.render unless @options[:quiet]
      Sass::Util.silence_sass_warnings {_to_tree.render}
    end
  end
end
