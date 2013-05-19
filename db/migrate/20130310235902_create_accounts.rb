class CreateAccounts < ActiveRecord::Migration
  
  def up
    unless table_exists? :accounts
      create_table :accounts do |t|

        t.integer  :user_id
        
        t.string   :uid
        t.string   :balanced_uri

        t.string   :first_name
        t.string   :last_name
        t.string   :phone_number
        t.string   :street_address
        t.string   :zipcode
        t.string   :city
        t.string   :state
        t.string   :country

        t.string   :avatar
        t.integer  :current_balance

        t.timestamps
      end
        add_index :accounts, :user_id
        add_index :accounts, :uid
    end
  end
  
  def down
    drop_table :accounts if table_exists? :accounts
  end
  
end
