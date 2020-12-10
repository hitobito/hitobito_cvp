require 'spec_helper'

describe Structure::Steps::RoleType do
  let(:bund) { Structure::GroupRow.new(1, 'CVP Schweiz', nil) }
  let(:rows) { [bund] }
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

  it 'moves sympathisant from mitglieder to sympathisant sibling' do
    config[:roles_new][:moves] = [{
      from: 'Mitglieder',
      to: 'Sympathisanten',
      label: 'Sympathisant',
      type: 'Sympathisant'
    }]
    rows.first.type = 'Bund'

    mitglieder = Structure::GroupRow.new(2, 'Mitglieder', 1, bund).tap { |r| r.type = 'BundMitglieder' }
    sympis = Structure::GroupRow.new(3, 'Sympathisanten', 1, bund).tap { |r| r.type = 'BundSympathisanten' }
    bund.children = [mitglieder, sympis]
    rows << mitglieder
    rows << sympis

    verbindungen = double("Verbindungen")
    allow(verbindungen).to receive(:find_in_batches).and_yield([
      Verbindung.new(struktur_id: 2,
                     kunden_id_1: 1,
                     datum_von: now,
                     datum_bis: now,
                     merkmal: Merkmal.new(merkmal_bezeichnung_d: 'Sympathisant'))
    ])
    allow(subject).to receive(:verbindungen).and_return(verbindungen)
    subject.apply_roles
    expect(sympis.roles).to be_present
    expect(sympis.roles.first.type).to eq 'Sympathisant'
  end
end
