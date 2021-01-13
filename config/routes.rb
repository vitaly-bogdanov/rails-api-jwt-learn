Rails.application.routes.draw do
  post '/sing-up', controller: 'token', action: 'sing_up'
  post '/refresh', controller: 'token', action: 'refresh'
end
