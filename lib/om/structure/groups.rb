module Structure
  class Groups

    COLUMNS = %i[verbandstruktur_id bezeichnung_d ref_verbandstruktur_id]

    STEPS = [
      Structure::Steps::Delete,
      Structure::Steps::Move,
      Structure::Steps::Adopt,
      Structure::Steps::MoveUp,
      Structure::Steps::GroupType,
      Structure::Steps::RoleType,
      Structure::Steps::Hierarchy
    ]

    MAPPINGS = {
      ag: [1, 29, 151],
      ai: [1, 29, 152],
      ar: [1, 29, 153],
      be: [1, 29, 154],
      be_jura: [1, 29, 155],
      bl: [1, 29, 156],
      bs: [1, 29, 157],
      fr: [1, 29, 158],
      ge: [1, 29, 159],
      gl: [1, 29, 160],
      gr: [1, 29, 161],
      ju: [1, 29, 162],
      lu: [1, 29, 163],
      ne: [1, 29, 164],
      nw: [1, 29, 165],
      ow: [1, 29, 166],
      sg: [1, 29, 167],
      sh: [1, 29, 168],
      so: [1, 29, 169],
      sz: [1, 29, 170],
      tg: [1, 29, 171],
      ti: [1, 29, 172],
      ur: [1, 29, 173],
      vd: [1, 29, 174],
      vs_ober: [1, 29, 175],
      vs_romand: [1, 29, 176],
      csp_ow: [1, 40284],
      zg: [1, 29, 177],
      zh: [1, 29, 5181],
      bund_jcvp: [1, 2],
      bund_frauen: [1, 3],
      bund_seniors: [1, 4],
      bund_awg: [1, 5],
      bund_csv: [1, 6],
      bund_politik: [1, 7],
      bund_fraktion: [1, 8],
      bund_kontakte: [1, 9],
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

    def build
      STEPS.inject(rows) do |rows, step|
        step.new(rows, config).run
      end.select(&:present?)
    end

    def scope
      @scope ||= build_scope
    end

    def build_scope
      scope = @group_ids ? ancestors_with_descendants : Verband.all
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
