# Description:  seeds marketing products with default products

desc "Seed Marketing Products"

task :seed_marketing_products => :environment do
  puts "Running seed_marketing_products task: "

  MarketingProduct.create(  :name => 'Posters',
                  :zazzle_template_id => '228487745845865189',
                  :price_in_cents => 1340,
                  :image => File.open('app/assets/images/marketing_products/poster.png'),
                  :comment => 'Highly visible')

  MarketingProduct.create(  :name => 'Buttons',
                  :zazzle_template_id => '145148411050634326',
                  :price_in_cents => 330,
                  :image => File.open('app/assets/images/marketing_products/button.png'),
                  :comment => 'Face-to-face interaction')
=begin
# cannot get qr code to scan on coffee mugs, temporarily take them off the list until we can come up with a solution. or maybe just leave them off the list permanently.
  MarketingProduct.create(  :name => 'Coffee Mugs',
                  :zazzle_template_id => '168510652836819209',
                  :price_in_cents => 1695,
                  :image => File.open('app/assets/images/marketing_products/coffee_mug.png'),
                  :comment => 'Give a gift that gives back')
=end
  MarketingProduct.create(  :name => 'Business Cards',
                  :zazzle_template_id => '240314513419822309',
                  :price_in_cents => 2395,
                  :image => File.open('app/assets/images/marketing_products/business_card.png'),
                  :comment => 'Great for handing out')

  MarketingProduct.create(  :name => 'Wall Decals',
                  :zazzle_template_id => '256607172338881257',
                  :price_in_cents => 1895,
                  :image => File.open('app/assets/images/marketing_products/wall_decal.png'),
                  :comment => 'Giant reusable stickers')

  MarketingProduct.create(  :name => 'Stickers',
                  :zazzle_template_id => '217970799043890191',
                  :price_in_cents => 575,
                  :image => File.open('app/assets/images/marketing_products/sticker.png'),
                  :comment => 'Just stick and forget')

  MarketingProduct.create(  :name => 'T-Shirts',                  
                  :zazzle_template_id => '235203023181485035',
                  :price_in_cents => 1695,
                  :image => File.open('app/assets/images/marketing_products/t_shirt.png'),
                  :comment => 'Wearable fundraising')

  MarketingProduct.create(  :name => 'Postcards',
                  :zazzle_template_id => '239855738817094597',
                  :price_in_cents => 98,
                  :image => File.open('app/assets/images/marketing_products/post_card.png'),
                  :comment => 'Send and receive')

  puts "Task seed_marketing_products complete!"
 

end