# Your website's host name
SitemapGenerator::Sitemap.default_host = "http://" + ENV['HOST']

# The remote host where your sitemaps will be hosted
SitemapGenerator::Sitemap.sitemaps_host = "http://" + ENV['AWS_BUCKET'] + ".s3.amazonaws.com/"

# The directory to write sitemaps to locally
SitemapGenerator::Sitemap.public_path = 'tmp/'

# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
SitemapGenerator::Sitemap.sitemaps_path = 'sitemap/'

# Instance of `SitemapGenerator::WaveAdapter`
SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new


SitemapGenerator::Sitemap.create do
  add root_path, :priority => 1
  add about_path, :priority => 0.7
  add fund_path(ENV['SWIFTGIVE_FUND_UID']), :priority => 0.7 if ENV['SWIFTGIVE_FUND_UID'].present?
  add contact_path, :priority => 0.2
  add terms_path, :priority => 0.1
  add privacy_path, :priority => 0.1

  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.zone.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
