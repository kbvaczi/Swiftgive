class AddImageToMarketingProducts < ActiveRecord::Migration
    def up
      add_column(:marketing_products, :image, :text)	   unless column_exists?(:marketing_products, :image)
      add_column(:marketing_products, :comment, :text)	   unless column_exists?(:marketing_products, :comment)
      remove_column(:marketing_products, :picture_url)     if column_exists?(:marketing_products, :picture_url)
    end

    def down
      add_column(:marketing_products, :picture_url, :text)		unless column_exists?(:marketing_products, :picture_url)
      remove_column(:marketing_products, :comment, :text)	   	if column_exists?(:marketing_products, :comment)
      remove_column(:marketing_products, :image)				if column_exists?(:marketing_products, :image)
    end
end