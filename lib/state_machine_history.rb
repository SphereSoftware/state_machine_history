$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
require 'lib/machine_history'
require 'rubygems'
require 'state_machine'

module StateMachineHistory

  class InvalidState < StandardError
  end
  
  def self.included(base)
    base.class_eval do
      
      def track_history
        self.owner_class.class_eval do
          has_one :machine_log, :as => :loggable
        end
        
        before_transition(any => any) do |object, transition|
          MachineHistory.create(:loggable => object,
            :from_state=>transition.from_name.to_s, :to_state=>transition.to_name.to_s,
            :event=>transition.event.to_s )
        end
      end
      
      alias_method :define_event_helpers_original, :define_event_helpers

      def define_event_helpers
        define_event_helpers_original

        # Define the method which determines whether we visited a state before current or particular one
        define_instance_method(:was_there?) do |machine, object, from_state, to_state|
          to_state ||= object.state
          from_state = from_state.to_s
          to_state = to_state.to_s

          is_from_state = machine.states.detect {|item| item.name.to_s == from_state}
          raise InvalidState, "\"#{from_state}\" is an unknown state machine state" unless is_from_state
          
          is_to_state = machine.states.detect {|item| item.name.to_s == to_state}
          raise InvalidState, "\"#{to_state}\" is an unknown state machine state" unless is_to_state
          
          history = MachineHistory.find(:last, :conditions => {:loggable_id => object.id,
            :to_state => to_state})

          next false if history.nil?

          date = history.created_at
          is_state = MachineHistory.find(:last,
            :conditions => ["loggable_id = ? and from_state = ? and created_at <= ?",
            object.id, from_state, date])
          
          is_state ? true : false
        end
      end

    end
  end
  
end

class StateMachine::Machine
  include StateMachineHistory
end