module Structure
  class Groups

    COLUMNS = %i[verbandstruktur_id bezeichnung_d ref_verbandstruktur_id]

    STEPS = [
      Structure::Steps::Group::Delete,
      Structure::Steps::Group::Move,
      Structure::Steps::Group::Adopt,
      Structure::Steps::Group::MoveUp,
      Structure::Steps::Group::Type,
      Structure::Steps::Group::Hierarchy,
      Structure::Steps::Group::Create,
      Structure::Steps::Group::Rename,
    ]

    ROLE_STEPS = [
      Structure::Steps::Role::Type,
      Structure::Steps::Role::Merkmale,
    ]

    BUND_GEWAEHLTE = [14763, 14860, 14861]
    WITH_BUND_GEWAEHLTE = [29] + BUND_GEWAEHLTE

    MAPPINGS = {
      ag: [1, WITH_BUND_GEWAEHLTE, 151],
      ai: [1, WITH_BUND_GEWAEHLTE, 152],
      ar: [1, WITH_BUND_GEWAEHLTE, 153],
      be: [1, WITH_BUND_GEWAEHLTE, 154],
      be_jura: [1, WITH_BUND_GEWAEHLTE, 155],
      bl: [1, WITH_BUND_GEWAEHLTE, 156],
      bs: [1, WITH_BUND_GEWAEHLTE, 157],
      fr: [1, [WITH_BUND_GEWAEHLTE, 14763, 14860, 14861], 158],
      ge: [1, WITH_BUND_GEWAEHLTE, 159],
      gl: [1, WITH_BUND_GEWAEHLTE, 160],
      gr: [1, [WITH_BUND_GEWAEHLTE, 14763, 14860, 14861], 161],
      ju: [1, WITH_BUND_GEWAEHLTE, 162],
      lu: [1, WITH_BUND_GEWAEHLTE, 163],
      ne: [1, WITH_BUND_GEWAEHLTE, 164],
      nw: [1, WITH_BUND_GEWAEHLTE, 165],
      ow: [1, WITH_BUND_GEWAEHLTE, 166],
      sg: [1, WITH_BUND_GEWAEHLTE, 167],
      sh: [1, WITH_BUND_GEWAEHLTE, 168],
      so: [1, WITH_BUND_GEWAEHLTE, 169],
      sz: [1, WITH_BUND_GEWAEHLTE, 170],
      tg: [1, WITH_BUND_GEWAEHLTE, 171],
      ti: [1, WITH_BUND_GEWAEHLTE, 172],
      ur: [1, WITH_BUND_GEWAEHLTE, 173],
      vd: [1, WITH_BUND_GEWAEHLTE, 174],
      vs_ober: [1, WITH_BUND_GEWAEHLTE, 175],
      vs_romand: [1, WITH_BUND_GEWAEHLTE, 176],
      csp_ow: [1, BUND_GEWAEHLTE, 40284],
      zg: [1, WITH_BUND_GEWAEHLTE, 177],
      zh: [1, WITH_BUND_GEWAEHLTE, 5181],
      bund_jcvp: [1, 2],
      bund_frauen: [1, 3],
      bund_seniors: [1, 4],
      bund_awg: [1, 5],
      bund_csv: [1, 6],
      bund_politik: [1, 7],
      bund_fraktion: [1, 8],
      bund_kontakte: [1, 9],
      bund_other: [
        1, WITH_BUND_GEWAEHLTE,
        [
          19,
          22,
          25,
          27,
          28,
          31,
          32,
          33,
          34,
          35,
          4864,
          4871,
          33146,
          36234,
          37444,
          37755,
          37839,
          38209,
          38210,
          38222,
          38819,
          38974,
          39709,
          39716,
          40418,
          40419,
          40420,
          40421,
          40422,
          40423]

      ]
    }.freeze

    def initialize(group_ids: nil, depth: nil, scope: nil)
      @group_ids = group_ids
      @depth = depth
      @scope = scope
    end

    def rows
      @rows ||= scope.pluck(*COLUMNS).collect do |columns|
        GroupRow.new(*columns)
      end
    end

    def build_groups
      STEPS.inject(rows) do |rows, step|
        step.new(rows, config).run
      end
    end

    def apply_roles(groups)
      ROLE_STEPS.inject(groups) do |rows, step|
        step.new(rows, config).run
      end
    end


    def build
      groups = build_groups
      groups_with_roles = apply_roles(groups)
      groups_with_roles.select(&:present?)
    end

    def scope
      @scope ||= build_scope
    end

    def build_scope
      scope = @group_ids != [1] ? ancestors_with_descendants : Verband.all
      scope = scope.where('depth <= ?', @depth) if @depth
      scope.order(:depth)
    end

    def ancestors_with_descendants
      ancestors = Verband.where(verbandstruktur_id: @group_ids.flatten)
      with_descendants(ancestors)
    end

    def with_descendants(scope)
      Verband.where(verbandstruktur_id: @group_ids.last).inject(scope) do |s, verband|
        s.or(Verband.where('lft > :lft AND rgt < :rgt', verband.slice(:lft, :rgt)))
      end
    end

    def config(path = File.join(File.dirname(__FILE__), '../import/config.yml'))
      @config ||= YAML.load_file(path).deep_symbolize_keys
    end
  end
end
