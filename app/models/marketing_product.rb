class MarketingProduct < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'marketing_products'
  
  attr_accessible :name, :image, :comment, :zazzle_template_id, :price_in_cents, :is_active

  default_scope where(:is_active => true)

  mount_uploader :image, MarketingProductImageUploader

  # ----- Validations ----- #

  validates_uniqueness_of :zazzle_template_id
                        
  # ----- Callbacks ----- #
    
  # ----- Member Methods ----- #

  def link_to_product(params = {})
    #TODO: figure out what characters are not allowed ('#' doesn't work, but only prohibits sendng correct fund name, so not a big deal)
    
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

#http://www.zazzle.com/api/create/at-238963925078453068?ax=Linkover&ed=true&fwd=ProductPage&ic=&pd=145726043656272339&rf=238963925078453068&t_givecode_iid=https%3A%2F%2Fswiftgive-development.s3.amazonaws.com%2Ffunds%2Ff_63be80bd%2Fgive_code.pdf&t_text0_txt=My+first+fund&t_text_txt=My+first+fund&tc=