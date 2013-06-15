class CreateFundsWithdraws < ActiveRecord::Migration
  def up
  	unless table_exists? :funds_withdraws
      create_table :funds_withdraws do |t|
        t.integer :fund_id
        t.integer :bank_account_id
        
        t.integer :amount_in_cents
        t.integer :commission_in_cents
        t.integer :balanced_fee_in_cents
        t.integer	:amount_to_receiver_in_cents
        t.string	:status

        t.string  :uid
        t.string  :balanced_uri
        
        t.timestamps
      end
        add_index :funds_withdraws, :uid
        add_index :funds_withdraws, :fund_id
        add_index :funds_withdraws, :bank_account_id
        add_index :funds_withdraws, :status
    end
  end

  def down
  	drop_table :funds_withdraws if table_exists? :funds_withdraws
  end
end