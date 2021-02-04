require 'spec_helper'

describe Structure::Steps::Group::Create do
  let(:rows) {
    [Structure::GroupRow.new(1, 'CVP Schweiz', nil)]
  }
  let(:config) { { groups: { deleted: {}, ignored: [] } } }

  subject      { described_class.new(rows, config).run }

  it 'creates additional Sympathisaten group if missing' do
    config[:groups][:create] = {
      'Bund': %w(Sympathisanten)
    }
    allow(rows.first).to receive(:type).and_return('Bund')
    expect(subject).to have(2).items
    expect(subject.second.label).to eq 'Sympathisanten'
    expect(subject.second.type).to eq 'BundSympathisanten'
    expect(subject.second.parent_id).to eq 1
  end


  it 'creates additional Sekretariat group if missing' do
    config[:groups][:create] = {
      'Bund': %w(Sympathisanten Sekretariat)
    }
    allow(rows.first).to receive(:type).and_return('Bund')
    expect(subject).to have(3).items
    expect(subject.second.type).to eq 'BundSympathisanten'
    expect(subject.third.type).to eq 'BundSekretariat'
  end

  it 'creates additional Sekretariat group with specific label' do
    config[:groups][:create] = {
      'Bund': ['Sympathisanten', 'Sekretariat', 'Sekretariat:Wichtige Einladungen']
    }
    allow(rows.first).to receive(:type).and_return('Bund')
    expect(subject).to have(4).items
    expect(subject.third.type).to eq 'BundSekretariat'
    expect(subject.third.label).to eq 'Sekretariat'
    expect(subject.fourth.type).to eq 'BundSekretariat'
    expect(subject.fourth.label).to eq 'Wichtige Einladungen'
  end

  it 'does not create additional Sympathisaten group if present and name matches' do
    config[:groups][:create] = {
      'Bund': %w(Sympathisanten)
    }
    sympathisanten = Structure::GroupRow.new(2, 'Sympathisanten', 1)
    sympathisanten.type = 'BundSympathisanten'
    rows.first.children  << sympathisanten
    rows << sympathisanten
    allow(rows.first).to receive(:type).and_return('Bund')
    expect(subject).to have(2).items
    expect(subject.second.label).to eq 'Sympathisanten'
    expect(subject.second.type).to eq 'BundSympathisanten'
    expect(subject.second.parent_id).to eq 1
  end


  it 'creates additional Sympathisaten group if present and name matches' do
    config[:groups][:create] = {
      'Bund': %w(Sympathisanten)
    }
    sympathisanten = Structure::GroupRow.new(2, 'Sympis', 1)
    sympathisanten.type = 'BundSympathisanten'
    rows.first.children  << sympathisanten
    rows << sympathisanten
    allow(rows.first).to receive(:type).and_return('Bund')
    expect(subject).to have(3).items
  end
end
