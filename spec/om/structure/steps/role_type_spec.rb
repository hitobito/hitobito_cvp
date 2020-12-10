require 'spec_helper'

describe Structure::Steps::RoleType do
  let(:rows) {
    [Structure::GroupRow.new(1, 'CVP Schweiz', nil)]
  }
  let(:now) { Time.zone.now  }

  let(:config) {
    path = File.join(File.dirname(__FILE__), '../../../../lib/om/import/config.yml')
    YAML.load_file(path).deep_symbolize_keys
  }

  subject { described_class.new(rows, config) }

  it 'sets roles on row' do
    rows.first.type = 'Bund'
    verbindungen = double("Verbindungen")
    allow(verbindungen).to receive(:find_in_batches).and_yield([
      Verbindung.new(struktur_id: 1,
                     kunden_id_1: 1,
                     datum_von: now,
                     datum_bis: now,
                     merkmal: Merkmal.new(merkmal_bezeichnung_d: 'Gast'))
    ])
    allow(subject).to receive(:verbindungen).and_return(verbindungen)
    subject.apply_roles
    expect(rows.first.roles).to be_present
  end

  it 'ignores role if configured' do
    config[:roles_new][:ignored] = ['Gast']
    rows.first.type = 'Bund'
    verbindungen = double("Verbindungen")
    allow(verbindungen).to receive(:find_in_batches).and_yield([
      Verbindung.new(struktur_id: 1,
                     kunden_id_1: 1,
                     datum_von: now,
                     datum_bis: now,
                     merkmal: Merkmal.new(merkmal_bezeichnung_d: 'Gast'))
    ])
    allow(subject).to receive(:verbindungen).and_return(verbindungen)
    subject.apply_roles
    expect(rows.first.roles).to be_empty
  end
end
