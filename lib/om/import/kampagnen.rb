module Import
  class Kampagnen < Base

    # hier brauch ich die group id
    def run
      scope.find_in_batches do |batch|
        rows = batch.collect do |row|
          row.prepare.merge(group_id: bund.id)
        end
        upsert(InvoiceList, rows)
      end
    end

    def scope
      spenden = Spende.where(kunden_id: ::Person.pluck(:kunden_id))
      Kampagne.all_year.where(kampagnen_nummer: spenden.select(:kampagnen_nummer))
    end

    def bund
      @bund ||= Group::Bund.first
    end
  end
end
