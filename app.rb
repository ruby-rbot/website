require 'bundler'

Bundler.require :default

# ----------------------------------------------------


class User
  INACTIVE = 0
  ACTIVE = 1
  ADMIN = 2

  include DataMapper::Resource

  property :id, Serial
  property :username, String, :required => true, :unique => true, 
    :messages => {
      :presence => 'username is a required field',
      :is_unique => 'username not available'
    }
  property :email, String, :required => true, :unique => true,
    :format => :email_address,
    :messages => {
      :presence => 'email is a required field.',
      :is_unique => 'email is already in the system.',
      :format => 'invalid email.'
    }
  property :password, BCryptHash, :required => true,
    :messages => {
      :presence => 'password is a required field.'
    }
  property :status, Integer, :required => true, :default => User::INACTIVE

  # password confirmation validation

  attr_accessor :password_confirm

  validates_confirmation_of :password, :confirm => :password_confirm
  validates_with_method     :validate_password
  def validate_password
    return true if self.password_confirm.length >= 8
    [false, 'Password must be atleast 8 characters long']
  end
end

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db")
DataMapper.finalize.auto_migrate!

# ----------------------------------------------------

set :root, File.dirname(__FILE__)
set :sass, { :load_paths => [ "#{File.dirname(__FILE__)}/app/css" ] }

register Sinatra::AssetPack
assets {
  serve '/img', :from => './app/img'
  css :app, [
    '/css/style.css'
  ]
  js_compression  :uglifyjs
  css_compression :sass
}

# ----------------------------------------------------

get '/' do
  slim :index
end

get '/register' do
  slim :register
end

post '/register' do
  @user = User.new params
  if @user.save
    # TODO: send mail, redirect to login, ...
    'success'
  else
    slim :register
  end
end

# ----------------------------------------------------

# due to some very strange apache2/passenger related bug,
# until I figure this out as a quick workaround:
get '/rdoc' do
  redirect to('/rdoc/'), 303
end

