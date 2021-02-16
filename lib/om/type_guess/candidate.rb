module TypeGuess
  class Candidate
    def initialize(matcher)
      @matcher = matcher
    end

    def match(row)
      case @matcher
      when Hash then @matcher.fetch(:ids).include?(row.id)
      when Regexp then @matcher.match(row.label)
      when Array
        constraint, matcher = *@matcher
        row.constraint.match(constraint) && matcher.match(row.label)
      end
    end
  end
end
