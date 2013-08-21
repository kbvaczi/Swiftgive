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
  	#TODO: figure out what characters are not allowed
  	
  	default_params = { :rf => '238963925078453068',
  					   :tc => '',
  					   :ic => '',
  					   :ax => 'Linkover',	
  					   :pd => self.zazzle_template_id, # zazzle template ID
  					   :fwd => 'ProductPage',  # this is a link to product page
  					   :ed => 'true' } # user can customize the product

  	URI::HTTP.build({ :host  => 'www.zazzle.com',
  				 	  :path  => "/api/create/at-238963925078453068",
  				 	  :query => params.present? ? params.merge(default_params).to_query : default_params.to_query}).to_s
  end

  # ----- Class Methods ----- #
  
end