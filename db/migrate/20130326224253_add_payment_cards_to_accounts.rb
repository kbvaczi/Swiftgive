class AddPaymentCardsToAccounts < ActiveRecord::Migration
  def up
    unless table_exists? :accounts_payment_cards
      create_table :accounts_payment_cards do |t|
        t.integer :account_id

        t.string  :name_on_card
        t.string  :card_type
        t.string  :last_4_digits
        
        t.string  :balanced_uri    # balanced payments unique identifier
        t.boolean :is_default, :default => false
    
        t.timestamps
      end
        add_index :accounts_payment_cards, :account_id
    end
  end
  
  def down
    drop_table :accounts_payment_cards if table_exists? :accounts_payment_cards
  end
end
