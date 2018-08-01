Erp::Corporators::Engine.routes.draw do
	scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "backend/corporators" do
			resources :corporators do
				collection do
					post 'list'
					get 'corporator_details'
					get 'dataselect'
					put 'set_active'
					put 'set_inactive'
					put 'move_up'
          put 'move_down'
				end
			end
    end
  end
end