module TypeGuess
  class Roles < Base
    def type(row)
      yield(row) if block_given?
      guess = guess(row) || default(row)
      allowed?(guess, row.group_type) ? guess : "tbd:#{row.label}"
    end

    def guess(row)
      repo.fetch(row.group_type, []).find do |type_guess|
        type_guess.match(row)
      end&.type
    end

    def build_repo
      @config.collect do |group_type, configs|
        guesses = configs.collect do |target_type, candidate_configs|
          yield(target_type, candidate_configs) if block_given?
          candidates = candidate_configs.collect { |c| Candidate.new(c) }
          CandidateList.new(target_type.to_s, candidates)
        end.compact
        [group_type, guesses]
      end
    end

    def allowed?(guess, group_type)
      guess if Array(@allowed[group_type]).include?(guess)
    end

    def default(row)
      defaults.find { |type_guess| type_guess.match(row) }&.type
    end

    def defaults
      @defaults ||= @config[:defaults].to_h.collect do |target_type, candidate_configs|
        candidates = candidate_configs.collect { |c| Candidate.new(c) }
        CandidateList.new(target_type.to_s, candidates)
      end
    end
  end
end
