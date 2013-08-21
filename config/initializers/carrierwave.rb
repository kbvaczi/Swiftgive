CarrierWave.configure do |config|

  config.cache_dir = "#{Rails.root}/tmp/uploads"                    # this is required for heroku to work properly

  config.fog_credentials = {
    :provider               => 'AWS',                             # s3
    :aws_access_key_id      => ENV['aws_access_key_id'],          # login
    :aws_secret_access_key  => ENV['aws_secret_access_key'],      # password
    #:region                 => 'us-west-1'   
    #:host                   => "#{directory}.s3.amazonaws.com",             # optional, defaults to nil       
  }

  config.storage        = :fog
  config.fog_attributes = {'Cache-Control'=>'public, max-age=315576000'}  # set cache-control headers for uploaded files
  config.fog_directory  = ENV['AWS_BUCKET']
  
  
  
end