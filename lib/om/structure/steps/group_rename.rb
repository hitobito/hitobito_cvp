module Structure::Steps
  class GroupRename < Base

    def run
      @rows.each do |row|
        next unless applies?(row)

        row.label = renames.dig(row.type, :to)
      end
    end

    def applies?(row)
      renames.key?(row.type) && renames.dig(row.type, :from) == row.label
    end

    def renames
      @renames ||= @config.dig(:groups, :renames).to_h.with_indifferent_access
    end
  end
end
