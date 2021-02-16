module Structure::Steps
  class GroupType < Base

    def run
      @rows.each do |row|
        row.type = guesser.type(row)
      end
    end

    def guesser
      @guesser ||= TypeGuess::Groups.new(@config.dig(:groups, :types), allowed)
    end

    def allowed
      Group.all_types.each_with_object({}) do |type, memo|
        short_type = type.to_s.demodulize
        memo[short_type] ||= []
        memo[short_type] = type.children.collect do |child|
          child.to_s.demodulize
        end
      end
    end

  end
end
