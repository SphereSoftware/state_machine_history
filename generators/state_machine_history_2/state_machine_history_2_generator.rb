class StateMachineHistory2Generator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template "create_machine_history.rb", "db/migrate"
    end
  end

  def file_name
    'create_machine_history'
  end
end