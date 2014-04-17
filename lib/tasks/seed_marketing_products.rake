# Description:  seeds marketing products with default products

desc "Seed Marketing Products"

task :seed_marketing_products => :environment do
  Rails.logger.info "Running seed_marketing_products task: "
  
  MarketingProduct.create(	:name => 'Coffee Mugs',
  					   		:zazzle_template_id => '168185807055035381',
  					   		:price_in_cents => 1695,
  					   		:picture_url => 'http://swiftgive.s3.amazonaws.com/images/marketing_products/coffee_mug_thumb.png')

  MarketingProduct.create(	:name => 'T-Shirts',
  					   		:zazzle_template_id => '235650843591632302',
  					   		:price_in_cents => 2295,
  					   		:picture_url => 'http://swiftgive.s3.amazonaws.com/images/marketing_products/t_shirt_thumb.png')

  MarketingProduct.create(	:name => 'Buttons',
  					   		:zazzle_template_id => '145726043656272339',
  					   		:price_in_cents => 390,
  					   		:picture_url => 'http://swiftgive.s3.amazonaws.com/images/marketing_products/button_thumb.png')

  MarketingProduct.create(	:name => 'Stickers',
  					   		:zazzle_template_id => '217583298237345740',
  					   		:price_in_cents => 575,
  					   		:picture_url => 'http://swiftgive.s3.amazonaws.com/images/marketing_products/sticker_thumb.png')

  MarketingProduct.create(	:name => 'Wall Decals',
  					   		:zazzle_template_id => '256613350304605116',
  					   		:price_in_cents => 1895,
  					   		:picture_url => 'http://swiftgive.s3.amazonaws.com/images/marketing_products/wall_decal_thumb.png')

  Rails.logger.info "Task seed_marketing_products complete!"
end