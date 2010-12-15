$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
require 'lib/machine_log'


module StateMachineLog

  class InvalidState < StandardError
  end
  
  def self.included(base)
    base.class_eval do
      
      def logger
        before_transition(any => any) do |object, transition|
          log = MachineLog.new(:owner_id => object.id, :class_name => object.class,
            :from_state=>transition.from_name, :to_state=>transition.to_name,
            :event=>transition.event )
          log.save
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
          
          date = MachineLog.find(:last, :conditions => ["owner_id = ? and
            to_state = ?", object.id, to_state])

          next false if date.nil?

          date = date.created_at
          is_state = MachineLog.find(:last,
            :conditions => ["owner_id = ? and from_state = ? and created_at <= ?",
            object.id, from_state, date])
          
          is_state ? true : false
        end
      end

    end
  end
  
end

class StateMachine::Machine
  include StateMachineLog
end