class CreateFunds < ActiveRecord::Migration
  def up
    unless table_exists? :funds
      create_table :funds do |t|
        t.string  :uid
        t.string  :name

        t.string  :description
        t.text    :profile
        t.string  :give_code, :default => ""
        
        t.string  :creator_name
        t.string  :city
        t.string  :state

        t.string  :fund_type
        t.string  :business_name
        t.string  :business_email
                
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
        
        t.boolean  :is_owner, :default => false
        t.boolean  :is_creator, :default => false
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
