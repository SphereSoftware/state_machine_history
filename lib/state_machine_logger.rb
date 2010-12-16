$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
require 'lib/machine_log'
require 'rubygems'
require 'state_machine'

module StateMachineLogger

  class InvalidState < StandardError
  end
  
  def self.included(base)
    base.class_eval do
      
      def logger
        self.owner_class.class_eval do
          has_one :machine_log, :as => :logable
        end
        
        before_transition(any => any) do |object, transition|
          MachineLog.create(:logable => object,
            :from_state=>transition.from_name.to_s, :to_state=>transition.to_name.to_s,
            :event=>transition.event.to_s )
        end
      end
      
      alias_method :define_event_helpers_original, :define_event_helpers

      def define_event_helpers
        define_event_helpers_original

        # Define the method which determines the object is located in one state
        # before another state
        define_instance_method(:visit?) do |machine, object, from_state, to_state|
          to_state ||= object.state
          from_state = from_state.to_s
          to_state = to_state.to_s

          is_from_state = machine.states.detect {|item| item.name.to_s == from_state}
          raise InvalidState, "\"#{from_state}\" is an unknown state machine state" unless is_from_state
          
          is_to_state = machine.states.detect {|item| item.name.to_s == to_state}
          raise InvalidState, "\"#{to_state}\" is an unknown state machine state" unless is_to_state
          
          date = MachineLog.find(:last, :conditions => ["logable_id = ? and
            to_state = ?", object.id, to_state])

          next false if date.nil?

          date = date.created_at
          is_state = MachineLog.find(:last,
            :conditions => ["logable_id = ? and from_state = ? and created_at <= ?",
            object.id, from_state, date])
          
          is_state ? true : false
        end
      end

    end
  end
  
end

class StateMachine::Machine
  include StateMachineLogger
end