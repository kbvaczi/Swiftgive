class CreatePayments < ActiveRecord::Migration
  def up
    unless table_exists? :payments
      create_table :payments do |t|
        t.integer :fund_id
        t.integer :sender_id
        
        t.string  :uid
        t.integer :amount
        t.text    :message
        t.boolean :is_anonymous, :default => :true
        
        t.timestamps
      end
        add_index :payments, :uid
        add_index :payments, :fund_id
        add_index :payments, :sender_id        
    end
  end

  def down
    drop_table :payments if table_exists? :payments
  end
end
