class CreateBankAccounts < ActiveRecord::Migration

  def up
    unless table_exists? :bank_accounts
      create_table :bank_accounts do |t|
        t.string  :fund_id
        t.string  :user_id        

        t.string   :uri # balanced payments unique identifier
        t.string   :bank_name
        t.string   :owner_name
        t.string   :last_4_digits
        t.string   :account_type
        t.boolean  :is_debitable, :default => false
        
        t.timestamps
      end
        add_index :bank_accounts, :fund_id
        add_index :bank_accounts, :user_id        
    end
  end

  def down
    drop_table :bank_accounts if table_exists? :bank_accounts
  end
  
end