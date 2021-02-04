require 'spec_helper'

describe Structure::Merkmal::List do
  def build_group(id, type, parent = nil)
    parent_id = parent&.id
    parent_depth = parent&.depth.to_i

    Structure::GroupRow.new(id, type, parent_id, parent).tap do |row|
      row.type = type
    end
  end

  let(:bund) { build_group(1, 'Bund') }
  let(:bund_arbeitsgruppe) { build_group(2, 'BundArbeitsgruppe', bund ) }

  let(:csv) do
    <<~CSV
    Merkmal,Gruppen,Anzahl,Neue Gruppe,Rolle
    AG Schulraumplanung,Group::OrtPraesidium,2,Group::OrtGewaehlte,Group::OrtGewaehlte::MitgliedWeitereGemeindeKommissionen
    ARA Kommission,Group::OrtPraesidium,2,Group::OrtGewaehlte,Group::OrtGewaehlte::MitgliedWeitereGemeindeKommissionen
    Abonnent Newsletter,Group::Ort,1,Group::OrtArbeitsgruppe,Group::OrtArbeitsgruppe::Mitglied
    Basic Card,Group::BundArbeitsgruppe,8,Group::BundArbeitsgruppe,Group::BundArbeitsgruppe::Mitglied
    CSV
  end

  subject { described_class.new(StringIO.new(csv)) }

  it 'returns role onchanged if no mapping is found' do
    role = Structure::RoleRow.new(bund_arbeitsgruppe, nil, 'Abonnent Newsletter', nil)
    expect do
      subject.build(role)
    end.not_to change { role.type }
  end

  it 'returns move if found' do
    role = Structure::RoleRow.new(bund_arbeitsgruppe, nil, 'Basic Card', nil)
    expect do
      subject.build(role)
    end.to change { role.type }.from(nil).to 'Mitglied'
  end
end
