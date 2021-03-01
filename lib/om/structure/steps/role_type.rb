module Structure::Steps
  class RoleType < Base

    def run
      apply_roles
      apply_mitgliedschaften
      @rows
    end

    def apply_roles
      find_in_batches(verbindungen)
    end

    def apply_mitgliedschaften
      find_in_batches(mitgliedschaften)
    end

    def find_in_batches(scope)
      scope.find_in_batches do |batch|
        batch.each do |obj|
          next if ignored?(obj.label)

          group = lookup_group(obj)
          role = Structure::RoleRow.new(group,
                                        obj.kunden_id,
                                        obj.label,
                                        obj.timestamps)

          role.type = guesser.type(role)
          group.roles << role
        end
      end
    end

    def lookup_group(obj)
      group = rows_by_id.fetch(obj.struktur_id)
      move = moves.find { |m| group.type.ends_with?(m[:from]) && m[:label].match?(obj.label) }
      return group unless move

      moved_to = group.parent.children.find { |child| child.type.ends_with?(move[:to]) }
      moved_to || fail("Move failed:  #{obj}")
    end

    def moves
      @moves ||= @config.dig(:roles_new, :moves)
    end

    def rows_by_id
      @rows_by_id ||= @rows.index_by(&:id)
    end

    def guesser
      @guesser ||= TypeGuess::Roles.new(@config.dig(:roles_new, :types), allowed)
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
      ::Role.all_types.each_with_object({}) do |type, memo|
        group_type = type.module_parent.to_s.demodulize
        memo[group_type] ||= []
        memo[group_type] << type.to_s.demodulize
      end
    end

    def ignored?(label)
      @config.dig(:roles_new, :ignored).any? { |r| r.match(label) }
    end
  end
end
