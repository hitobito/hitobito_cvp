module Import
  class Base
    def self.run(*args)
      obj = new(*args)
      obj.measured { obj.run }
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

    def group_ids
      Groups.instance.by_id.keys
    end

    def group_type(id)
      Groups.instance.get(id).type
    end

    def group_name(id)
      Groups.instance.get(id).name
    end

    def fetch_person_id(uuid)
      @people ||= ::Person.pluck(:kunden_id, :id).to_h
      @people.fetch(uuid)
    end
  end
end
