module Erp::Corporators
  class Corporator < ApplicationRecord
    include Erp::CustomOrder
    
    mount_uploader :image_url, Erp::Contacts::ContactUploader
    validates :name, presence: true
    validates_format_of :email, :allow_blank => true, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => " is invalid (Eg. 'user@domain.com')"

    belongs_to :creator, class_name: "Erp::User", optional: true

    belongs_to :parent, class_name: "Erp::Corporators::Corporator", foreign_key: :parent_id, optional: true
    has_many :corporators, class_name: 'Erp::Corporators::Corporator', foreign_key: :parent_id

    MAIN_CONTACT_ID = 1

    if Erp::Core.available?("areas")
      belongs_to :country, class_name: "Erp::Areas::Country", optional: true
      belongs_to :state, class_name: "Erp::Areas::State", optional: true
      belongs_to :district, class_name: "Erp::Areas::District", optional: true

      # country name
      def country_name
        country.present? ? country.name : ''
      end

      # state name
      def state_name
        state.present? ? state.name : ''
      end
      
      # district name
      def district_name
        district.present? ? district.name : ''
      end
    end

    # class const
    GENDER_MALE = 'male'
    GENDER_FEMALE = 'female'
    TYPE_LEADERSHIP = 'leadership'
    TYPE_OWNERSHIP = 'ownership'
    STATUS_ACTIVE = 'active'
    STATUS_INACTIVE = 'inactive'

    # get gender for contact
    def self.get_gender_options()
      [
        {text: I18n.t('male'),value: self::GENDER_MALE},
        {text: I18n.t('female'),value: self::GENDER_FEMALE}
      ]
    end
    
    # get type options type corporators
    def self.get_corporator_type_options()
      [
        {text: I18n.t('erp.corporators.backend.corporators.leadership'),value: self::TYPE_LEADERSHIP},
        {text: I18n.t('erp.corporators.backend.corporators.ownership'),value: self::TYPE_OWNERSHIP}
      ]
    end
    
    # get active
    def self.all_active
      self.where(status: self::STATUS_ACTIVE)
    end

    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []

      # show archived items condition - default: false
      show_archived = false

      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            # in case filter is show archived
            if cond[1]["name"] == 'show_archived'
              # show archived items
              show_archived = true
            elsif cond[1]["name"] != 'in_period_active'
              or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
            end
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end

      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end

      # join with users table for search creator
      query = query.joins(:creator)

      ## showing archived items if show_archived is not true
      #query = query.where(archived: false) if show_archived == false

      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(erp_orporators_orporators.cache_search) LIKE ?', '%'+q+'%')
				end
			end

      return query
    end

    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end

    # data for dataselect ajax
    def self.dataselect(keyword='', params='')

      query = self.all_active
      
      if params[:corp_type].present?
        query = query.where(corp_type: params[:corp_type])
      end
      
      if params[:parent_id].present?
        query = query.where(parent_id: params[:parent_id])
			end
      
      if keyword.present?
				keyword = keyword.strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(erp_corporators_corporators.cache_search) LIKE ?', '%'+q+'%')
				end
			end

      if params[:corporator_id].present?
        query = query.where.not(id: params[:corporator_id])
      end

      query = query.limit(25).map{|corporator| {value: corporator.id, text: corporator.name} }
    end

    # corporator birthday
    def corporator_birthday
			birthday.present? ? birthday : nil
		end

    ## Get main corporator
    #def self.get_main_corporator
    #  #@todo: hard code
    #  return Corporator.find(self::MAIN_CORPORATOR_ID)
    #end
    
    # force generate code
    after_create :generate_code
    def generate_code
      letter_code = 'SH'
      
      query = Erp::Corporators::Corporator.all
      
      num = query.where('created_at <= ?', self.created_at).count
      
      self.code = "#{letter_code}-#{num.to_s.rjust(4, '0')}"
      self.save
		end
    
    # Update cache search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << code.to_s.downcase.strip
			str << name.to_s.downcase.strip
			str << phone.to_s.downcase.strip if phone.present?
			str << email.to_s.downcase.strip if email.present?

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end

    def parent_code
      parent.nil? ? '' : parent.code
    end

    def parent_name
      parent.nil? ? '' : parent.name
    end
    
    # set status
		def set_active
			update_attributes(status: Erp::Corporators::Corporator::STATUS_ACTIVE)
		end

		def set_inactive
			update_attributes(status: Erp::Corporators::Corporator::STATUS_INACTIVE)
		end
		
		# check status
		def is_active?
			return self.status == Erp::Corporators::Corporator::STATUS_ACTIVE
		end
		
		def is_inactive?
			return self.status == Erp::Corporators::Corporator::STATUS_INACTIVE
		end
    
    # get leadership corporators
    def self.get_leadership_corporators
      Erp::Corporators::Corporator.where(corp_type: Erp::Corporators::Corporator::TYPE_LEADERSHIP)
    end
  end
end
