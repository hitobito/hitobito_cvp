module Import
  class Base
    def self.run(*args)
      obj = new(*args)
      obj.measured { obj.run }
    end

    def initialize(groups = nil)
      @groups = groups
    end

    def measured(label = self.class.name)
      @start_time = Time.zone.now
      puts "Starting #{label}"
      res = yield
      puts "Finished #{label} #{upsert_summary} - duration: #{duration}"
      res
    end

    def upsert_summary
      upserts.collect do |model, count|
        [model.name, count].join(": ")
      end.join(', ').presence
    end

    def upsert(model, rows)
      model.upsert_all(rows, returning: false).tap do
        upserts[model] += rows.size
      end
    end

    def upserts
      @upserts ||= Hash.new(0)
    end

    def time_diff(start_time, end_time)
      seconds_diff = (start_time - end_time).abs
      Time.at(seconds_diff).utc.strftime '%H:%M:%S'
    end

    def duration
      time_diff(@start_time, Time.zone.now)
    end

    def validate_sti(model_class)
      model_class.pluck(Arel.sql('distinct type')).each(&:constantize)
    rescue => e
      puts "Invalid type for #{model_class} - #{e}"
    end

    def groups
      @groups ||= Structure::Groups.new(scope: group_scope).build
    end

    def kunden_ids
      groups.flat_map { |g| g.roles.collect(&:kunden_id) }.uniq
    end

    def group_scope
      ::Verband.all.order(:depth).where(verbandstruktur_id: Group.pluck(:id))
    end

    def fetch_person_id(uuid)
      @@people ||= ::Person.pluck(:kunden_id, :id).to_h
      @@people.fetch(uuid)
    end
  end
end
