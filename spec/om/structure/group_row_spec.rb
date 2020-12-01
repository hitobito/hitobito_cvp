
require 'spec_helper'

describe Structure::GroupRow do
  let(:rows) { [Structure::GroupRow.new(1, 'CVP Schweiz', nil),
                Structure::GroupRow.new(29, 'Kantonalparteien', 1),
                Structure::GroupRow.new(159, 'CVP SG', 29)] }

  it 'indents to_s' do
    Structure::Steps::Adopt.new(rows).run
    expect(rows.first.to_s).to start_with('<')
    expect(rows.second.to_s).to start_with(' <')
    expect(rows.third.to_s).to start_with('  <')
  end

  def row_with_type(id, label, parent_id, type)
    Structure::GroupRow.new(id, label, parent_id).tap do |row|
      row.type = type
    end
  end


  context 'blank' do
    it 'is blank if it has no children or roles' do
      row = Structure::GroupRow.new(1, 'Dummy', 0)
      expect(row).to be_blank
    end

    it 'is not blank if it has roles' do
      row = Structure::GroupRow.new(1, 'Dummy', 0)
      row.roles << [Structure::RoleRow.new(row, '1', 'Dummy')]
      expect(row).not_to be_blank
    end

    it 'is blank if it has children but children are blank' do
      row = Structure::GroupRow.new(1, 'Dummy', 0)
      child = Structure::GroupRow.new(1, 'Dummy', 0)

      expect(child).to be_blank
      expect(row).to be_blank
      row.children = [child]
      expect(row).to be_blank
    end

    it 'is not blank if any child is a mitglieder group' do
      row = Structure::GroupRow.new(1, 'Dummy', 0)
      child = Structure::GroupRow.new(1, 'Mitgliedschaften', 0)
      child.type = 'Ort::Mitglieder'
      expect(child).not_to be_blank
      row.children = [child]
      expect(row).not_to be_blank
    end
  end

  context 'sorting' do

    it 'sorts non layer before layer' do
      rows = [row_with_type(2, 'CVP SG', 1, 'Kanton'),
              row_with_type(2, 'AG', 1, 'KantonArbeitsgruppe'),]
      expect(rows.sort.first.label).to eq 'AG'
    end

    it 'by label if type is the same' do
      rows = [row_with_type(2, 'CVP SG', 1, 'Kanton'),
              row_with_type(2, 'CVP AG', 1, 'Kanton'),]
      expect(rows.sort.first.label).to eq 'CVP AG'
    end
  end

end
