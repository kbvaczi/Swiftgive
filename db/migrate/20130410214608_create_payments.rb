class CreatePayments < ActiveRecord::Migration
  def up
    unless table_exists? :payments
      create_table :payments do |t|
        t.integer :fund_id
        t.integer :sender_id
        
        t.integer :amount_in_cents
        t.text    :message
        t.string  :sender_name_from_email
        t.string  :sender_email
        t.string  :receiver_email

        t.boolean :is_anonymous, :default => :true            # Sender name will not show up in public view
        t.boolean :is_confirmed_by_email, :default => :false  # We received a copy of the email sent to square cash for this payment
        t.boolean :is_cancelled, :default => :false           # The sender subsequently cancelled the payment.  Receiver will have to manually set this?

        t.string  :uid
        
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
