SinLab::Application.routes.draw do

  resources :decks

  resources :cartoes, :except => [:destroy, :create, :new] do
    collection do
      post :atualizar_trello
      get :find_or_create
      get :dados
    end
  end

  resources :estimativas, :only => [:index, :create] do
    collection do
      get 'board/:board_id' => "estimativas#board", :as => :board
      get 'cartao/:cartao_id' => "estimativas#cartao", :as => :cartao
      get :fechar_rodada
      post :nova_rodada
      post :concluir
    end
  end

  resources :atividades, :only => [:update, :destroy] do
    collection do
      get  :validacao
      post :aprovar
      post :mensagens
      post :enviar_mensagem
      post :ajax_form
    end
  end

  resources :pagamentos do
    collection do
      get  :periodos
      get  :listar
    end
  end

#  namespace :android do
#    resources :tokens,:only => [:create, :destroy]
#    get 'meses/:id/dias' => "meses#dias"
#    get "meses/index"
#  end


  #devise_for :users, :controllers => {:passwords => "users/passwords", :registrations => "users/registrations", :sessions => "users/sessions"}

  devise_for :usuarios, controllers: {usuarios: "usuarios"}

  devise_scope :usuarios do
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end

  resources :usuarios, :controller => "usuarios" do
    collection do
      post :custom_create
      get :get_id_by_nome
      get :alt_role
      get :coordenados
      get "coordenados/dados" => "usuarios#coordenadodados"
    end
  end

  resources :projetos, :except => [:new, :show] do
    collection do
      get ':id/campos_cadastro' => "projetos#campos_cadastro"
      post :coordenadorform
      post  :atividades
    end
  end

  resources :coordenacoes

  resources :workons

  resources :dias do
    collection do
      get :periodos
      get :cartao_pai
      get :cartao_tags
      get :atualizar_tags_cartoes
    end
  end

  resources :ausencias, :only => [:index, :destroy, :create, :new, :update] do
    collection do
      post :validar
      post :ausencia
    end
  end

  get "/uploads/:id/:basename.:extension", :controller => "anexos", :action => "download"

  root :to => "dias#index"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
