class MarketingProduct < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'marketing_products'
  
  attr_accessible :name, :picture_url, :zazzle_template_id, :price_in_cents, :is_active

  default_scope where(:is_active => true)

  # ----- Validations ----- #

  validates_uniqueness_of :zazzle_template_id
                        
  # ----- Callbacks ----- #
    
  # ----- Member Methods ----- #

  def link_to_product(params = {})
  	URI::HTTP.build({:host  => 'www.zazzle.com',
  				 	 :path  => "/#{self.zazzle_template_id}",
  				 	 :query => params.present? ? params.to_query : nil}).to_s
  end

  # ----- Class Methods ----- #
  
  
end
