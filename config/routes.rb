Rails.application.routes.draw do
  devise_for :users, path: '',
                     path_names: {
                       sign_in: 'login',
                       sign_out: 'logout',
                       registration: 'signup'
                     },
                     controllers: {
                       sessions: 'users/sessions',
                       registrations: 'users/registrations'
                     }
  get '/users/assigned_hours', to: 'users/assigned_hours#index'

  resources :services, only: %i[index show] do
    resources :service_weeks, only: %i[show edit]
  end
end
