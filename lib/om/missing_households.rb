require "csv"
class MissingHouseholds
  Row = Struct.new(:address, :town, :zip_code, :count, :person_ids) do
    def valid?
      count > 1
    end

    def ids
      @ids ||= person_ids.split(",")
    end

    def <=>(other)
      if ids.size == other.ids.size
        address <=> other.address
      else
        ids.size <=> other.ids.size
      end
    end

    def people
      @people ||= ids.collect { |id| Query.find(id) }
    end

    def names
      people.collect(&:to_s).join(" & ")
    end

    def to_s
      [address, town, zip_code, names].join(" - ")
    end
  end

  class << self
    def write
      columns = %w(address town zip_code names count person_ids)
      CSV.open("potential_households.csv", "wb") do |csv|
        csv << columns
        addresses.each do |addr|
          csv << columns.collect { |col| addr.send(col) }
        end
      end
    end


    def addresses
      @addresses ||= scope
        .group(:address, :town, :zip_code)
        .pluck("address, town, zip_code, count(id), group_concat(id)")
        .collect { |row| Row.new(*row) }
        .select(&:valid?)
        .sort
    end

    def find(id)
      @people ||= Person.where(id: addresses.collect(&:ids).flatten).index_by(&:id)
      @people.fetch(id.to_i)
    end

    def scope
      @scope ||= Person.where(company: false).with_address.where(household_key: nil)
    end

    def people
      scope.minimal.where(id: addresses.selec)
    end
  end
end
