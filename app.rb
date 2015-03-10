require 'bundler'

Bundler.require :default

set :root, File.dirname(__FILE__)

register Sinatra::AssetPack
assets {
  serve '/img', :from => './app/img'
  css :app, [
    '/css/style.css'
  ]
  js_compression  :uglifyjs
  css_compression :sass
}

get '/' do
  haml :index
end

# due to some very strange apache2/passenger related bug,
# until I figure this out as a quick workaround:
get '/rdoc' do
  redirect to('/rdoc/'), 303
end

