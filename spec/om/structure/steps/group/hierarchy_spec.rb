require 'spec_helper'

describe Structure::Steps::Group::Hierarchy do
  it 'builds depth first' do
    rows = [
      Structure::GroupRow.new(1, 'CVP Schweiz', nil),
      Structure::GroupRow.new(2, 'CVP SG', 1),
      Structure::GroupRow.new(3, 'CVP BE', 1),
      Structure::GroupRow.new(4, 'Gossau', 2),
      Structure::GroupRow.new(5, 'Burgdorf', 3),
      Structure::GroupRow.new(6, 'Partei Gossau', 4),
      Structure::GroupRow.new(7, 'Partei Burgdorf', 5),
    ]

    sorted = described_class.new(rows).run
    expect(sorted.collect(&:label)).to eq [
      'CVP Schweiz',
      'CVP BE',
      'Burgdorf',
      'Partei Burgdorf',
      'CVP SG',
      'Gossau',
      'Partei Gossau',
    ]
  end

  it 'ignores groups whos parents are missing' do
    rows = [
      Structure::GroupRow.new(1, 'CVP Schweiz', nil),
      Structure::GroupRow.new(3, 'CVP BE', 1),
      Structure::GroupRow.new(4, 'Gossau', 2),
      Structure::GroupRow.new(5, 'Burgdorf', 3),
    ]

    sorted = described_class.new(rows).run
    expect(sorted.collect(&:label)).to eq [
      'CVP Schweiz',
      'CVP BE',
      'Burgdorf',
    ]
  end

end
