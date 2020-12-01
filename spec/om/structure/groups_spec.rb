require 'spec_helper'

describe Structure::Groups do

  let(:config) {
    path = File.join(File.dirname(__FILE__), '../../../lib/om/import/config.yml')
    YAML.load_file(path).deep_symbolize_keys
  }
  let(:rows) { [Structure::GroupRow.new(1, 'CVP Schweiz', nil),
                Structure::GroupRow.new(29, 'Kantonalparteien', 1),
                Structure::GroupRow.new(159, 'CVP SG', 29)] }


  it 'runs all operations' do
    expect(subject).to receive(:rows).and_return(rows)

    result = subject.build
    expect(result).to have(2).items
    expect(result.first.type).to eq 'Bund'
    expect(result.second.type).to eq 'Kanton'
  end
end
