module TypeGuess
  class Groups < Base

    def type(row)
      return 'Bund' if row.root?

      guess = guess(row) || default(row)
      allowed?(guess, row.parent_type) ? guess : 'tbd'
    end

    def guess(row)
      repo.fetch(row.parent_type, []).find do |type_guess|
        type_guess.match(row)
      end&.type
    end

    def allowed?(guess, parent_type)
      guess if Array(@allowed[parent_type]).include?(guess)
    end

    def default(row)
      @config.fetch(row.parent_type, {})[:default]
    end

    def build_repo
      @config.collect do |parent_type, configs|
        guesses = configs.collect do |target_type, candidate_configs|
          next if target_type.to_sym == :default
          candidates = candidate_configs.collect { |c| Candidate.new(c) }
          CandidateList.new(target_type.to_s, candidates)
        end.compact
        [parent_type, guesses]
      end
    end
  end
end
