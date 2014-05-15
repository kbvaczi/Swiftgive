# Description:  seeds marketing products with default products

desc "Seed Marketing Products"

task :seed_marketing_products => :environment do
  puts "Running seed_marketing_products task: "

  MarketingProduct.create(  :name => 'Posters',
                  :zazzle_template_id => '228723627312463596',
                  :price_in_cents => 1340,
                  :image => File.open('app/assets/images/marketing_products/poster.png'),
                  :comment => 'Highly visible')

  MarketingProduct.create(  :name => 'Buttons',
                  :zazzle_template_id => '145835469004797303',
                  :price_in_cents => 330,
                  :image => File.open('app/assets/images/marketing_products/button.png'),
                  :comment => 'Face-to-face interaction')

  MarketingProduct.create(  :name => 'Coffee Mugs',
                  :zazzle_template_id => '168510652836819209',
                  :price_in_cents => 1695,
                  :image => File.open('app/assets/images/marketing_products/coffee_mug.png'),
                  :comment => 'Give a gift that gives back')

  MarketingProduct.create(  :name => 'Business Cards',
                  :zazzle_template_id => '240745151292290233',
                  :price_in_cents => 2395,
                  :image => File.open('app/assets/images/marketing_products/business_card.png'),
                  :comment => 'Great for handing out')

  MarketingProduct.create(  :name => 'Wall Decals',
                  :zazzle_template_id => '256948617127289090',
                  :price_in_cents => 1895,
                  :image => File.open('app/assets/images/marketing_products/wall_decal.png'),
                  :comment => 'Giant reusable stickers')

  MarketingProduct.create(  :name => 'Stickers',
                  :zazzle_template_id => '217386779406632965',
                  :price_in_cents => 575,
                  :image => File.open('app/assets/images/marketing_products/sticker.png'),
                  :comment => 'Just stick and forget')

  MarketingProduct.create(  :name => 'T-Shirts',                  
                  :zazzle_template_id => '235403812552985696',
                  :price_in_cents => 1695,
                  :image => File.open('app/assets/images/marketing_products/t_shirt.png'),
                  :comment => 'Wearable fundraising')

  MarketingProduct.create(  :name => 'Postcards',
                  :zazzle_template_id => '239323549612494494',
                  :price_in_cents => 98,
                  :image => File.open('app/assets/images/marketing_products/post_card.png'),
                  :comment => 'Send and receive')

  puts "Task seed_marketing_products complete!"
 

end