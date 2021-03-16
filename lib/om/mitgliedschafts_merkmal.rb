class MitgliedschaftsMerkmal < ActiveRecord::Base
  establish_connection(adapter: :postgresql)
  self.table_name = 'mitgliedschaft_merkmal'
  belongs_to :mitgliedschaft, foreign_key: :mitgliedschaftsnummer, primary_key: :mitgliedschafts_nummer

  belongs_to :merkmal, ->(o) { where(merkmal_gruppe: o.hauptcode) }, foreign_key: :untercode, primary_key: :merkmal

  EINTRITT = 7019
  AUSTRITT = 7022

  scope :entritt, -> { where(hauptcode: EINTRITT) }
  scope :austritt, -> { where(hauptcode: AUSTRITT) }

  def to_s
    merkmal.to_s
  end

  def eintritt?
    hauptcode == EINTRITT.to_s
  end

  def austritt?
    hauptcode == AUSTRITT.to_s
  end
end
