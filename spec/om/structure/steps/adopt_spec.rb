require 'spec_helper'

describe Structure::Steps::Adopt do
  let(:rows) {
    [Structure::GroupRow.new(1, 'CVP Schweiz', nil),
     Structure::GroupRow.new(2, 'Kantonalparteien', 1),
     Structure::GroupRow.new(3, 'CVP SG', 2)]
  }

  subject { described_class.new(rows, {}).run }

  it 'sets parent on each row' do
    expect(subject).to have(3).items
    expect(subject.second.parent).to eq rows[0]
    expect(subject.third.parent).to eq rows[1]
  end
end
