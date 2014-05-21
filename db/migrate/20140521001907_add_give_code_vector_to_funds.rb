class AddGiveCodeVectorToFunds < ActiveRecord::Migration
	def up
		add_column(:funds, :give_code_image, :string)			unless column_exists?(:funds, :give_code_image)
		add_column(:funds, :give_code_vector, :string)		unless column_exists?(:funds, :give_code_vector)
		remove_column(:funds, :give_code)						if column_exists?(:marketing_products, :give_code)
    end

    def down
    	add_column(:funds, :give_code, :string)					unless column_exists?(:funds, :give_code)
    	remove_column(:funds, :give_code_image)						if column_exists?(:marketing_products, :give_code_image)
    	remove_column(:funds, :give_code_image)						if column_exists?(:marketing_products, :give_code_image)    	
    end
end
