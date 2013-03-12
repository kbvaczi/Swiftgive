class CreateUsersAuthentications < ActiveRecord::Migration
  
  def up
    unless table_exists? :users_authentications
      create_table :users_authentications do |t|
        t.integer :user_id
        
        t.string :provider
        t.string :uid
        t.text   :omniauth_data
        
        t.timestamps
      end
        add_index :users_authentications, :uid
        add_index :users_authentications, :provider
    end
  end
  
  def down
    drop_table :users_authentications if table_exists? :users_authentications
  end
  
end
