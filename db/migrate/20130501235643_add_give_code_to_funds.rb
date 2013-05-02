class AddGiveCodeToFunds < ActiveRecord::Migration
  def up
  	add_column(:funds, :give_code, :string, :default => '')     unless column_exists?(:funds, :give_code)
  end

  def down
  	remove_column(:funds, :give_code)     if column_exists?(:funds, :give_code)      
  end
end
