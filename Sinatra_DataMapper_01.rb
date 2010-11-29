require 'rubygems'
# require 'dm-core'
require 'UrlMinified.rb'
require 'sinatra'
require 'haml'
require 'uri'

UrlMinified.init

get '/' do
  @full_url = @token = nil
  haml :index
end
post "/" do
  if params['full_url'] && params['full_url'].length > 0
    @full_url = params['full_url']
    @token = UrlMinified.add(@full_url)
    parsed_uri = URI::parse(request.url)
    parsed_uri.path = "/g/#{@token}"
    @token_path = parsed_uri.to_s
  else
    @full_url = @token = nil
  end
  haml :index
end
get '/g/:token' do
  full_url = UrlMinified.get(params[:token])
  if full_url && full_url.length > 0
    redirect full_url
  else
    redirect "/tokennotfound/#{params[:token]}"
  end
end
get '/tokennotfound/:token' do
  @token = params[:token]
  haml :TokenNotFound
end
