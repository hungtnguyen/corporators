module Erp
  module Corporators
    module Backend
      class CorporatorsController < Erp::Backend::BackendController
        before_action :set_corporator, only: [:edit, :update, :destroy, :move_up, :move_down,
                                              :set_active, :set_inactive]
        
        # GET /corporators
        def index
        end
        
        # POST /corporators/list
        def list
          @corporators = Corporator.search(params).paginate(:page => params[:page], :per_page => 10)
          
          render layout: nil
        end
        
        def corporator_details
          @corporator = Corporator.find(params[:id])
          
          render layout: nil
        end
    
        # GET /corporators/new
        def new
          @corporator = Corporator.new
          @corporator.corp_type = params[:corp_type].present? ? params[:corp_type] : Corporator::TYPE_LEADERSHIP
        end
    
        # GET /corporators/1/edit
        def edit
          authorize! :update, @corporator
        end
    
        # POST /corporators
        def create
          @corporator = Corporator.new(corporator_params)
          @corporator.creator = current_user
          @corporator.set_inactive

          if @corporator.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @corporator.corporator_name,
                value: @corporator.id
              }
            else
              redirect_to erp_corporators.backend_corporators_path, notice: t('.success')
            end
          else
            render :new
          end
        end
    
        # PATCH/PUT /corporators/1
        def update
          authorize! :update, @corporator
          if @corporator.update(corporator_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @corporator.corporator_name,
                value: @corporator.id
              }
            else
              redirect_to erp_corporators.backend_corporators_path, notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /corporators/1
        def destroy
          authorize! :destroy, @corporator
          @corporator.destroy

          respond_to do |format|
            format.html { redirect_to erp_corporators.backend_corporators_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        # Active /corporators/set_active?id=1
        def set_active
          authorize! :set_active, @corporator
          @corporator.set_active

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end
        
        # Inactive /corporators/set_inactive?id=1
        def set_inactive
          authorize! :set_inactive, @corporator
          @corporator.set_inactive

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end
        
        # Move up /corporators/up?id=1
        def move_up
          @corporator.move_up

          respond_to do |format|
          format.json {
            render json: {
            #'message': t('.success'),
            #'type': 'success'
            }
          }
          end
        end

        # Move down /corporators/up?id=1
        def move_down
          @corporator.move_down

          respond_to do |format|
          format.json {
            render json: {
            #'message': t('.success'),
            #'type': 'success'
            }
          }
          end
        end
        
        def dataselect
          respond_to do |format|
            format.json {
              render json: Corporator.dataselect(params[:keyword], params)
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_corporator
            @corporator = Corporator.find(params[:id])
          end
    
          # Only allow a trusted parameter "white list" through.
          def corporator_params
            params.fetch(:corporator, {}).permit(
              :parent_id, :image_url, :corp_type, :code, :name, :birthday, :gender,
              :country_id, :state_id, :district_id, :address,
              :phone, :hotline, :email, :website, :fax, :tax_code, :note,
              :roll, :seniority, :job_qualification, :profile_album_id, 
              #corporator_ids: []
            )
          end
      end
    end
  end
end
