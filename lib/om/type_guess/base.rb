module TypeGuess
  class Base
    class_attribute :constraint

    def initialize(config, allowed = {})
      @config = config.with_indifferent_access
      @allowed = allowed.with_indifferent_access
    end

    def repo
      @repo ||= build_repo.to_h
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
