require 'spec_helper'

describe Structure::Steps::Delete do
  let(:rows) {
    [Structure::GroupRow.new(1, 'CVP Schweiz', nil),
     Structure::GroupRow.new(2, 'Kantonalparteien', 1),
     Structure::GroupRow.new(3, 'CVP SG', 2)]
  }
  let(:config) { { groups: { deleted: {}, ignored: [] } } }

  subject      { described_class.new(rows, config).run }

  it 'deletes rows and move parents by id' do
    config[:groups][:deleted] = [[2, 1]].to_h
    expect(subject).to have(2).items
    expect(subject.second.label).to eq 'CVP SG'
    expect(subject.second.parent_id).to eq 1
  end

  it 'deletes rows by regex if they have no children' do
    config[:groups][:ignored] = ['/CVP SG/']
    expect(subject).to have(2).items
    expect(subject.last.label).to eq 'Kantonalparteien'
  end
end
