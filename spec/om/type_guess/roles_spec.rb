require 'spec_helper'

describe TypeGuess::Roles do
  let(:config) { { OrtMitglieder: { Mitglied: [ /Mitglied/ ] } } }
  let(:allowed) { { OrtMitglieder: %w(Mitglied) } }

  it 'returns type for match' do
    row = double(:row, label: 'Mitglied', group_type: 'OrtMitglieder')
    expect(TypeGuess::Roles.new(config, allowed).type(row)).to eq 'Mitglied'
  end

  it 'constraints match by name' do
    row = double(:row, label: 'Mitglied', group_type: 'OrtMitglieder', constraint: 'Sympathisant')
    config[:OrtMitglieder][:Mitglied].prepend(%w(Sympathisant Mitglied))
    expect(TypeGuess::Roles.new(config, allowed).type(row)).to eq 'Mitglied'
  end

  it 'returns type tbd if it finds no match' do
    row = double(:row, label: 'Sympi', group_type: 'OrtMitglieder')
    expect(TypeGuess::Roles.new(config, allowed).type(row)).to eq 'tbd:Sympi'
  end

  it 'validates that guessed_type is allowed' do
    row = double(:row, label: 'Mitglied', group_type: 'OrtMitglieder')
    allowed.merge!(OrtMitglieder: [])
    expect(TypeGuess::Roles.new(config, allowed).type(row)).to eq 'tbd:Mitglied'
  end
end
