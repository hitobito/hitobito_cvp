
module Source
  class Groups

    def list

    end

    def ordered

    end

    def move

    end

    def delete
    end

    def scope
      scope = if @tree_name
                leaves = Array(::Verband.find(tree_ids.last))
                scope = ::Verband.where(verbandstruktur_id: tree_ids)
                leaves.inject(scope) do |s, leaf|
                  s.or(leaf.self_and_descendants.unscope(:order))
                end
              else
                scope = ::Verband.all
              end
      scope = @depth ? scope.where('depth < ?', @depth) : scope
      scope.order(:depth)
    end
  end
end
