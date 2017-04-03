Rails.application.routes.draw do
  root to: 'game#game'

  get 'game', to: 'game#game'
  get 'score', to: 'game#score'

end
