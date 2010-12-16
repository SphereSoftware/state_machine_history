class MachineHistory < ActiveRecord::Base
  belongs_to :loggable, :polymorphic => true

  validates_presence_of :loggable, :event, :from_state, :to_state
end