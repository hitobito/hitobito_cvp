
require 'spec_helper'

describe TypeGuess::CandidateList do
  Row = Struct.new(:id, :label)
1
  it 'type_guess matches if any candidate matches' do
    row = Row.new(1, 'CVP Schweiz')
    candidate = TypeGuess::Candidate.new(/schweiz/i)
    expect(TypeGuess::CandidateList.new('Bund', [candidate]).match(row)).to be_truthy
  end
end

