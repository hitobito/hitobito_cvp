module Import
  class Spenden < Base
    # hier brauch ich die group id
    def run
      scope.minimal.find_in_batches do |batch|
        rows = batch.collect do |row|
          group_id = bund.id
          list = lists[row['kampagnen_nummer']]
          person_id = people[row['kunden_id']]

          row.prepare.merge(
            id: row.spenden_nummer,
            state: :payed,
            group_id: group_id,
            sequence_number: next_number(group_id),
            esr_number: '',
            title: list&.title || 'Unbekannt',
            recipient_id: person_id,
            invoice_list_id: list&.id,
          )
        end
        upsert(Invoice, rows)
        upsert(Payment, payments_for(rows))
      end
      InvoiceList.find_each(&:update_total)
      InvoiceList.find_each(&:update_paid)
      update_invoice_config
    end

    def update_invoice_config
      sequence_number = @numbers[bund.id]
      Group::Bund.first.invoice_config.update_columns(sequence_number: sequence_number)
    end

    def payments_for(rows)
      rows.collect do |row|
        {
          id: row[:id],
          invoice_id: row[:id],
          amount: row[:total],
          received_at: row[:created_at]
        }
      end
    end

    def people
      @people ||= ::Person.pluck(:kunden_id, :id).to_h
    end

    def scope
      @scope ||= Spende.where(kunden_id: people.keys)
    end

    def lists
      @lists ||= InvoiceList.all.index_by(&:id)
    end

    def bund
      @bund ||= Group::Bund.first
    end

    def next_number(group_id)
      @numbers ||= Hash.new(0)
      value = @numbers[group_id] += 1
      [group_id, value].join('-')
    end
  end
end

