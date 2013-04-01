class AddStripeAccountsToFunds < ActiveRecord::Migration
  def up
    unless table_exists? :funds_stripe_accounts
      create_table :funds_stripe_accounts do |t|
        t.string  :fund_id

        t.string  :stripe_access_token
        t.string  :stripe_refresh_token
        t.string  :stripe_publishable_key
        t.string  :stripe_user_id
        t.text    :stripe_access_response      
        
        t.timestamps
      end
        add_index :funds_stripe_accounts, :fund_id
    end
  end
  
  def down
    drop_table :funds_stripe_accounts if table_exists? :funds_stripe_accounts
  end
  
end
