class CreateMachineLog < ActiveRecord::Migration
  def self.up
    create_table :machine_logs do |t|
      t.column :owner_id, :integer
      t.column :class_name, :string
      t.column :from_state, :string
      t.column :to_state, :string
      t.column :event, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :machine_logs
  end
end
