class AddPaymentCardsToUsers < ActiveRecord::Migration
  def up
    unless table_exists? :users_payment_cards
      create_table :users_payment_cards do |t|
        t.integer :user_id

        #t.string  :description
        t.string  :stripe_customer_id
        #t.boolean :is_default, :default => false
        t.text    :stripe_customer_object
    
        t.timestamps
      end
        add_index :users_payment_cards, :user_id
    end
  end
  
  def down
    drop_table :users_payment_cards if table_exists? :users_payment_cards
  end
end
