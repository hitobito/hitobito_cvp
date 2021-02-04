require 'spec_helper'

describe Structure::Merkmal::Builder do
  def build_group(id, type, parent = nil)
    parent_id = parent&.id
    parent_depth = parent&.depth.to_i

    Structure::GroupRow.new(id, type, parent_id, parent).tap do |row|
      row.type = type
    end
  end

  def build_role(group, label, type = 'tbd')
    Structure::RoleRow.new(group, nil, label, nil).tap do |r|
      r.type = type
      group.roles << r
    end
  end

  let(:bund) { build_group(1, 'Bund') }
  let(:bund_arbeitsgruppe) { build_group(2, 'BundArbeitsgruppe', bund ) }
  let(:role) { build_role(bund_arbeitsgruppe, 'Basic Card') }
  let(:row_template) {
    {
      "Merkmal":"Basic Card",
      "Gruppen":"Group::BundArbeitsgruppe",
      "Neue Gruppe":"Group::BundArbeitsgruppe",
    }
  }

  subject do
    described_class.new(Structure::Merkmal::Row.new(row.stringify_keys), role)
  end

  describe 'within same group' do
    let(:row) { row_template.merge("Rolle":"Group::BundArbeitsgruppe::Mitglied") }

    it 'changes role' do
      expect { subject.build }.to change { role.type }.from('tbd').to 'Mitglied'
    end
  end

  describe 'within layer' do
    let(:row) {
      row_template.merge(
        "Neue Gruppe": "Group::BundExterneKontakte",
        "Rolle": "Group::BundArbeitsgruppe::Mitglied"
      )
    }

    let(:bund_externe_kontakte) { build_group(2, 'BundExterneKontakte', bund) }

    before do
      bund.children = [bund_arbeitsgruppe, bund_externe_kontakte]
    end

    it 'changes group' do
      expect { subject.build }.to change { role.group.type }.from('BundArbeitsgruppe').to 'BundExterneKontakte'
    end

    it 'changes role' do
      expect { subject.build }.to change { role.type }.from('tbd').to 'Mitglied'
    end

    it 'removes role from group#roles and moves it to new_group#roles' do
      subject
      expect { subject.build }.to change { bund_arbeitsgruppe.roles.size }.from(1).to(0).
        and change { bund_externe_kontakte.roles.size }.from(0).to(1)
    end
  end

  describe 'in below layer' do
    let(:row) { row_template.merge({
      "Gruppen":"Group::KantonArbeitsgruppe",
      "Rolle":"Group::BundArbeitsgruppe::Mitglied",
    }) }
    let(:kanton) { build_group(3, 'Kanton', bund) }
    let(:kanton_arbeitsgruppe) { build_group(4, 'KantonArbeitsgruppe', kanton) }
    let(:bund_arbeitsgruppe) { build_group(5, 'BundArbeitsgruppe', bund) }

    let(:role) { build_role(kanton_arbeitsgruppe, 'Basic Card') }

    before do
      bund.children = [bund_arbeitsgruppe, kanton]
      kanton.children = [kanton_arbeitsgruppe]
    end

    it 'changes group' do
      expect { subject.build }.to change { role.group.type }.from('KantonArbeitsgruppe').to 'BundArbeitsgruppe'
    end

    it 'changes role' do
      expect { subject.build }.to change { role.type }.from('tbd').to 'Mitglied'
    end
  end

  describe 'in above layer' do
    let(:row) { row_template.merge({
      "Gruppen":"Group::BundSekretariat",
      "Rolle":"Group::KantonArbeitsgruppe::Leitung",
      "Neue Gruppe":"Group::KantonArbeitsgruppe",
    }) }
    let(:bund_sekretariat) { build_group(3, 'BundSekretariat', bund) }
    let(:bund_arbeitsgruppe) { build_group(5, 'BundArbeitsgruppe', bund) }
    let(:bund_arbeitsgruppe_basic_card) { build_group(4, 'BundArbeitsgruppe', bund) }

    let(:role) do
      build_role(bund_sekretariat, 'Basic Card') do |role|
        role.type = 'Group::BundArbeitsgruppe::Leitung'
      end
    end

    before do
      bund_arbeitsgruppe_basic_card.label = "Basic Card"
      bund.children = [bund_arbeitsgruppe, bund_arbeitsgruppe_basic_card]
    end

    it 'changes group' do
      expect { subject.build }.to change { role.group }.from(bund_sekretariat).to(bund_arbeitsgruppe_basic_card)
    end

    it 'changes role' do
      expect { subject.build }.to change { role.type }.from('tbd').to 'Mitglied'
    end
  end

  describe 'find_group_for_role_group_by_label by role' do
    let(:exekutive) { instance_double(Structure::GroupRow, "exekutive", type: 'KantonGewaehlte', label: 'Exekutive') }
    let(:legislative) { instance_double(Structure::GroupRow,"legislative", type: 'KantonGewaehlte', label: 'Legislative') }

    subject do
      described_class
        .new(Structure::Merkmal::Row.new(row.stringify_keys), role)
        .find_group_for_role_group_by_label([legislative, exekutive].shuffle)
    end

    let(:row) {
      row_template.merge({
        "Neue Gruppe": "Group::KantonGewaehlte",
        "Rolle": "Group::KantonGewaehlte::KantonaleExekutive",
      })
    }

    it 'finds group exekutive based on Rolle' do
      expect(subject).to eq exekutive
    end
  end

  describe 'find_group_for_role_group_by_label' do
    let(:legislative) { instance_double(Structure::GroupRow,"legislative", type: 'KantonGewaehlte', label: 'Legislative') }

    subject do
      described_class
        .new(Structure::Merkmal::Row.new(row.stringify_keys), role)
        .find_group_for_role_group_by_label([legislative, exekutive].shuffle)
    end

    context "matches target_role with group label" do
      let(:exekutive) { instance_double(Structure::GroupRow, "exekutive", type: 'KantonGewaehlte', label: 'Exekutive') }

      let(:row) {
        row_template.merge({
          "Neue Gruppe": "Group::KantonGewaehlte",
          "Rolle": "Group::KantonGewaehlte::KantonaleExekutive",
        })
      }

      it 'finds exekutive because Rolle matches group label' do
        expect(subject).to eq exekutive
      end
    end

    context "matches group label with merkmal" do
      let(:exekutive) { instance_double(Structure::GroupRow, "exekutive", type: 'KantonGewaehlte', label: 'Kantonale Exekutiv Gruppe') }

      let(:row) {
        row_template.merge({
          "Neue Gruppe": "Group::KantonGewaehlte",
          "Rolle": "Group::KantonGewaehlte::KantonaleExekutive",
          "Merkmal": "Exekutiv"
        })
      }

      it 'finds exekutive because Rolle matches group label' do
        expect(subject).to eq exekutive
      end
    end
  end

end
