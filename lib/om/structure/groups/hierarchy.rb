module Structure
  class Groups::Hierarchy

    def initialize(group_ids: nil, depth: nil)
      @depth = depth
      @group_ids = group_ids
    end

    def formatted(format_role = nil)
      rows.collect do |row|
        row.to_s(format_role)
      end
    end

    def run(format_role = nil)
      puts formatted(format_role)
    end

    def rows
      @rows ||= Groups.new(group_ids: @group_ids, depth: @depth).build
    end

    def config(path = File.join(File.dirname(__FILE__), '../import/config.yml'))
      @config ||= YAML.load_file(path).deep_symbolize_keys
    end

  end
end

