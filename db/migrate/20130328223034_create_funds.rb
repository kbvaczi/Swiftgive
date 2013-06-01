class CreateFunds < ActiveRecord::Migration
  def up
    unless table_exists? :funds
      create_table :funds do |t|
        t.string  :uid
        t.string  :name

        t.string  :description
        t.text    :profile
        
        t.string  :merchant_name
        t.string  :merchant_date_of_birth
        t.string  :merchant_phone_number
        t.string  :merchant_street_address
        t.string  :merchant_postal_code
        t.string  :merchant_tax_id

        t.string  :fund_type
        t.string  :balanced_uri
        t.boolean :is_active, :default => true
        
        t.timestamps
      end
        add_index :funds, :uid
        add_index :funds, :name
        add_index :funds, :fund_type
    end
    
    unless table_exists? :funds_memberships
      create_table :funds_memberships do |t|
        t.integer  :account_id
        t.integer  :fund_id
        
        t.boolean :is_owner, :default => false
      end
      add_index   :funds_memberships, :account_id
      add_index   :funds_memberships, :fund_id
    end
  end
  
  def down
    drop_table :funds if table_exists? :funds
    drop_table :funds_memberships if table_exists? :funds_memberships    
  end
end
