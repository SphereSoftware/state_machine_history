class StateMachineLogSecondGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template "create_machine_log.rb", "db/migrate"
    end
  end
end