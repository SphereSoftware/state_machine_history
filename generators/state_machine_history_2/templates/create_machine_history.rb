class CreateMachineHistory < ActiveRecord::Migration
  def self.up
    create_table :machine_histories do |t|
      t.column :loggable_id, :integer
      t.column :loggable_type, :string
      t.column :from_state, :string
      t.column :to_state, :string
      t.column :event, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :machine_histories
  end
end
