module TypeGuess
  class CandidateList
    attr_reader :type

    def initialize(type, candidates)
      @type = type
      @candidates = candidates
    end

    def match(row)
      @candidates.any? { |c| c.match(row) }
    end
  end
end
