  if Rails.env.production?
    ENV['AWS_BUCKET'] = 'swiftgive'
  elsif Rails.env.staging?
    ENV['AWS_BUCKET'] = 'swiftgive-staging'
  else
    ENV['AWS_BUCKET'] = 'swiftgive-development'
  end