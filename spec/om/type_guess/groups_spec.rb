require 'spec_helper'

describe TypeGuess::Groups do
  let(:config) { { Bund: { Kanton: [ ids: [2] ] } } }
  let(:allowed) { { Bund: %w(Kanton) } }

  it 'returns type for match' do
    row = double(:row, id: 2, label: 'CVP AG', root?: false, parent_type: 'Bund')
    expect(TypeGuess::Groups.new(config, allowed).type(row)).to eq 'Kanton'
  end

  it 'returns tbd if it finds no match' do
    row = double(:row, id: 2, label: 'Unknown', root?: false, parent_type: nil)
    expect(TypeGuess::Groups.new(config, allowed).type(row)).to eq 'tbd'
  end

  it 'falls back to parent default' do
    row = double(:row, id: 3, label: 'Unknown', root?: false, parent_type: 'Bund')
    config.deep_merge!(Bund: { default: 'Kanton' })
    expect(TypeGuess::Groups.new(config, allowed).type(row)).to eq 'Kanton'
  end

  it 'validates that guess is allowed' do
    row = double(:row, id: 3, label: 'Kanton', root?: false, parent_type: nil)
    config[:Bund][:default] = 'Kanton'
    allowed[:Bund] = []
    expect(TypeGuess::Groups.new(config, allowed).type(row)).to eq 'tbd'
  end
end
