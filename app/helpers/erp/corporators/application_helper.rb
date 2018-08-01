module Erp
  module Corporators
    module ApplicationHelper
      
      # corporator dropdown actions
      def corporator_dropdown_actions(corporator)
        actions = []
        actions << {
          text: '<i class="fa fa-edit"></i> Chỉnh sửa',
          url: erp_corporators.edit_backend_corporator_path(corporator)
        } if can? :update, corporator
        
        actions << {
          text: '<i class="fa fa-check"></i> '+t('.set_active'),
          url: erp_corporators.set_active_backend_corporators_path(id: corporator.id),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.set_active_confirm')
        } if can? :set_active, corporator
        
        actions << {
          text: '<i class="fa fa-remove"></i> '+t('.set_inactive'),
          url: erp_corporators.set_inactive_backend_corporators_path(id: corporator),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.set_inactive_confirm')
        } if can? :set_inactive, corporator
        
        actions << {divider: true} if can? :destroy, corporator
        
        actions << {
          text: '<i class="fa fa-trash"></i> '+t('.delete'),
          url: erp_corporators.backend_corporator_path(corporator),
          data_method: 'DELETE',
          class: 'ajax-link',
          data_confirm: t('.delete_confirm')
        } if can? :destroy, corporator
        
        erp_datalist_row_actions(
          actions
        )
      end
      
    end
  end
end
