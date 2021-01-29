require 'spec_helper'

describe Structure::Steps::Group::Type do
  let(:rows) {
    [Structure::GroupRow.new(1, 'CVP Schweiz', nil),
     Structure::GroupRow.new(159, 'CVP SG', 1)]
  }

  let(:config) {
    path = File.join(File.dirname(__FILE__), '../../../../../lib/om/import/config.yml')
    YAML.load_file(path).deep_symbolize_keys
  }

  subject { described_class.new(rows, config) }

  it 'sets type on each row' do
    rows = subject.run
    expect(rows).to have(2).items
    expect(rows.first.type).to eq 'Bund'

    expect(rows.second.type).to eq 'Kanton'
  end

  it 'knows about allowed group types' do
    expect(subject.allowed['KantonGewaehlte']).to eq %w(KantonGewaehlte)
  end

end
