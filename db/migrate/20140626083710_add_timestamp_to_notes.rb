class AddTimestampToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :timestamp, :string
  end
end
