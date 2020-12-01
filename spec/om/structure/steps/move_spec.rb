require 'spec_helper'

describe Structure::Steps::Move do

  let(:rows) { [Structure::GroupRow.new(1, 'CVP Schweiz', nil),
                Structure::GroupRow.new(2, 'Kantonalparteien', 1),
                Structure::GroupRow.new(3, 'CVP SG', 2),
                Structure::GroupRow.new(4, 'CVP AG', 2)] }

  let(:config) { { groups: { moves: { by_parent_id: [], by_id: [] } } } }

  subject      { described_class.new(rows, config).run }

  it 'moves by parent_id' do
    config[:groups][:moves][:by_parent_id] = [[2,1]]

    expect(subject[2].parent_id).to eq 1
    expect(subject[3].parent_id).to eq 1
  end

  it 'moves by id' do
    config[:groups][:moves][:by_id] = [[3, 2], [4, 1]]
    expect(subject[2].parent_id).to eq 2
    expect(subject[3].parent_id).to eq 1
  end

  it 'moves by id after moving by parent_id' do
    config[:groups][:moves][:by_id] = [[4, 2]]
    config[:groups][:moves][:by_parent_id] = [[2, 1]]
    expect(subject[2].parent_id).to eq 1
    expect(subject[3].parent_id).to eq 2
  end
end
