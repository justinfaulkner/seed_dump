class SeedDump
  module Environment

    def dump_using_environment(env)
      Rails.application.eager_load!

      SeedDump.dump(Sample)
    end
  end
end

