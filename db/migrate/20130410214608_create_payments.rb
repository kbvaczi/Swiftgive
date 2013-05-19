class CreatePayments < ActiveRecord::Migration
  def up
    unless table_exists? :accounts_payments
      create_table :accounts_payments do |t|
        t.integer :fund_id
        t.integer :sender_id
        t.integer :payment_card_used_id
        
        t.string  :uid
        t.string  :balanced_uri
        
        t.integer :amount
        t.text    :message
        t.boolean :is_anonymous, :default => :true
        
        t.timestamps
      end
        add_index :accounts_payments, :uid
        add_index :accounts_payments, :fund_id
        add_index :accounts_payments, :sender_id
        add_index :accounts_payments, :payment_card_used_id        
    end
  end

  def down
    drop_table :accounts_payments if table_exists? :accounts_payments
  end
end
