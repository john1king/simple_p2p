Rails.application.routes.draw do

  root "home#index"

  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/docs'
end
