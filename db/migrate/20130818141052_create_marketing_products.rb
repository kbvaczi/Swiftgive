class CreateMarketingProducts < ActiveRecord::Migration
  def up
  	unless table_exists? :marketing_products
      create_table :marketing_products do |t|
        t.string  :name
        
        t.integer :price_in_cents
        t.string  :zazzle_template_id
        t.string  :picture_url

        t.boolean :is_active, :default => true
        
        t.timestamps
      end
        add_index :marketing_products, :name
        add_index :marketing_products, :zazzle_template_id
    end
  end

  def down
  	drop_table :marketing_products if table_exists? :marketing_products
  end
end