class CreatePayments < ActiveRecord::Migration
  def up
    unless table_exists? :payments
      create_table :payments do |t|
        t.integer :fund_id
        t.integer :withdraw_id
        t.integer :sender_id
        t.integer :payment_card_used_id
        
        t.text    :message
        t.boolean :is_anonymous, :default => :true
        
        t.integer :amount_in_cents
        t.integer :commission_in_cents
        t.float   :commission_percent
        t.integer :balanced_fee_in_cents
        t.integer :amount_to_receiver_in_cents

        t.string  :uid
        t.string  :balanced_uri        
        
        t.timestamps
      end
        add_index :payments, :uid
        add_index :payments, :fund_id
        add_index :payments, :sender_id
        add_index :payments, :withdraw_id
        add_index :payments, :payment_card_used_id
    end
  end

  def down
    drop_table :payments if table_exists? :payments
    drop_table :accounts_payments if table_exists? :accounts_payments
  end
end
