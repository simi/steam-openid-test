require 'sinatra/base'
require 'rack/openid'
require 'open-uri'
require 'json'

module Steam
  module Openid
    class Web < Sinatra::Base
      use Rack::Session::Cookie
      use Rack::OpenID

      STEAM_OPENID_ENDPOINT = "https://steamcommunity.com/openid/"

      get '/login' do
        erb :login
      end

      post '/login' do
        if resp = request.env["rack.openid.response"]
          if resp.status == :success
            steam_id = resp.display_identifier.split('/').last
            content = open("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s" % [ENV['API_KEY'], steam_id]) {|f| f.read}
            content = JSON.parse(content)
            "Your Steam name: #{content["response"]["players"][0]["personaname"]}"
          else
            "Error: #{resp.status}"
          end
        else
          headers 'WWW-Authenticate' => Rack::OpenID.build_header(
            :identifier => STEAM_OPENID_ENDPOINT
          )
          throw :halt, [401, 'got openid?']
        end
      end

      enable :inline_templates
    end
  end
end

__END__

@@ login
<form action="/login" method="post">
<p>
<input name="commit" type="submit" value="Get info" />
</p>
</form>
