class Merkmal < SourceModel
  self.table_name = :merkmal_stamm
  has_many :verbindungen, class_name: 'Verbindung', foreign_key: :merkmal_id

  has_many :mitgliedschafts_merkmale, class_name: 'MitgliedschaftsMerkmal'

  PUBLICATIONS = "7013"
  scope :publications, -> { where(merkmal_gruppe: PUBLICATIONS) }
  scope :publications_lu, -> { publications.where(merkmal: "14") } # CVP LU INFO


  # Kommt nicht über verbindungen (dort sind nur gruppe 7004 und 7044)
  def self.cvp_lu_info
    find_by(merkmal_bezeichnung_d: 'CVP LU Info') # merkmal_gruppe 7013
  end

  def to_s
    [merkmal_gruppe_bezeichnung_d, merkmal_bezeichnung_d].join(' ')
  end
end
