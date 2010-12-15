class MachineLog < ActiveRecord::Base
  set_table_name :machine_logs

  validates_presence_of :class_name, :event, :from_state, :owner_id, :to_state
end