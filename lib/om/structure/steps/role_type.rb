module Structure::Steps
  class RoleType < Base

    def initialize(rows, config = nil)
      super
      @ignored = @config[:roles_new].delete(:ignored)
    end

    def run
      apply_roles
      apply_mitgliedschaften
      @rows
    end

    def apply_roles
      find_in_batches(verbindungen) do |group, obj|
        Structure::RoleRow.new(group,
                               obj.kunden_id_1,
                               obj.merkmal.merkmal_bezeichnung_d,
                               obj.timestamps)
      end
    end

    def apply_mitgliedschaften
      find_in_batches(mitgliedschaften) do |group, obj|
        Structure::RoleRow.new(group,
                               obj.kunden_id,
                               obj.mitgliedschafts_bezeichnung,
                               obj.timestamps)
      end
    end

    def find_in_batches(scope)
      scope.find_in_batches do |batch|
        batch.each do |obj|
          group = rows_by_id.fetch(obj.struktur_id)
          role = yield(group, obj)
          next if ignored?(role.label)

          role.type = guesser.type(role)
          group.roles << role
        end
      end
    end

    def rows_by_id
      @rows_by_id ||= @rows.index_by(&:id)
    end

    def guesser
      @guesser ||= TypeGuess::Roles.new(@config[:roles_new], allowed)
    end

    # TODO we are ignoring some mitgliedschaften here
    def mitgliedschaften
      Mitgliedschaft.where(
        struktur_id: @rows.select(&:mitgliedschaft?).collect(&:id)
      ).mitglieder.minimal
    end

    def verbindungen
      Verbindung.includes(:merkmal).where(
        struktur_id: @rows.reject(&:mitgliedschaft?).collect(&:id)
      ).minimal
    end

    def allowed
      Role.all_types.each_with_object({}) do |type, memo|
        group_type = type.module_parent.to_s.demodulize
        memo[group_type] ||= []
        memo[group_type] << type.to_s.demodulize
      end
    end

    def ignored?(label)
      @ignored.any? { |r| r.match(label) }
    end
  end
end
