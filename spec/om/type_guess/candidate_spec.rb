require 'spec_helper'

describe TypeGuess::Candidate do
  it 'matches using regex' do
    row = double(:row, id: 1, label: 'CVP Schweiz')
    expect(TypeGuess::Candidate.new(/schweiz/i).match(row)).to be_truthy
  end

  it 'matches using hash checks id' do
    row = double(:row, id: 1, label: 'CVP SG')
    expect(TypeGuess::Candidate.new(ids: [1, 2]).match(row)).to be_truthy
  end

  it 'matches using constraint if array has two elements' do
    row = double(:row, id: 1, label: 'Mitglied', constraint: 'Exekutive')
    expect(TypeGuess::Candidate.new(['Exekutive', 'Mitglied']).match(row)).to be_truthy
  end

  it 'matches using constraint treats first element as regex' do
    row = double(:row, id: 1, label: 'Mitglied', constraint: 'Exekutive Kanton')
    expect(TypeGuess::Candidate.new(['^Exekutive$', 'Mitglied']).match(row)).not_to be_truthy
  end
end

