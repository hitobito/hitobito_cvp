class AddCvpMigrationFields < ActiveRecord::Migration[6.0]
  def change
    add_column(:groups, :kunden_id, :string, index: true)
    add_column(:roles, :mitgliedschafts_nummer, :string, index: true)

    change_table :people do |t|
      t.string :kunden_id, index: true
      t.integer :kundennummer, index: true
      t.integer :kontaktnummer, index: true
    end
  end
end
