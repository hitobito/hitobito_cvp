class MitgliedschaftsMerkmal < ActiveRecord::Base
  establish_connection(adapter: :postgresql)
  self.table_name = 'mitgliedschaft_merkmal'
  belongs_to :mitgliedschaft, foreign_key: :mitgliedschaftsnummer, primary_key: :mitgliedschafts_nummer

  belongs_to :merkmal, ->(o) { where(merkmal_gruppe: o.hauptcode) }, foreign_key: :untercode, primary_key: :merkmal

  def to_s
    merkmal.to_s
  end
end
