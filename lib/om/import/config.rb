module Import
  class Config
    class << self
      def config
        @config ||= YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml')).deep_symbolize_keys
      end

      def dig(*args)
        config.dig(*args)
      end

      def codes
        @verband_codes_regex ||= Regexp.new(dig(:verband, :codes_regex))
      end
    end
  end
end
