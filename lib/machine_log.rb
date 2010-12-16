class MachineLog < ActiveRecord::Base
  belongs_to :logable, :polymorphic => true

  validates_presence_of :event, :from_state, :to_state
end