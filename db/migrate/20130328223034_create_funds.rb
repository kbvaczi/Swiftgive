class CreateFunds < ActiveRecord::Migration
  def up
    unless table_exists? :funds
      create_table :funds do |t|
        t.string  :uid
        t.string  :name

        t.string  :description
        t.text    :profile
        
        t.timestamps
      end
        add_index :funds, :uid
        add_index :funds, :name
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
