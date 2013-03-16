class AddProfileDataToUser < ActiveRecord::Migration
  def up
    add_column(:users, :first_name, :string) unless column_exists? :users, :first_name
    add_column(:users, :last_name, :string)  unless column_exists? :users, :last_name    
    add_column(:users, :city, :string)       unless column_exists? :users, :city
    add_column(:users, :state, :string)      unless column_exists? :users, :state
    add_column(:users, :country, :string)    unless column_exists? :users, :country    
    add_column(:users, :image, :string)      unless column_exists? :users, :image
  end
  
  def down
    remove_column(:users, :first_name) if column_exists? :users, :first_name
    remove_column(:users, :last_name)  if column_exists? :users, :last_name    
    remove_column(:users, :city)       if column_exists? :users, :city
    remove_column(:users, :state)      if column_exists? :users, :state
    remove_column(:users, :country)    if column_exists? :users, :country    
    remove_column(:users, :image)      if column_exists? :users, :image
  end
end
