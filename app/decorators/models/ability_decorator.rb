Erp::Ability.class_eval do
  def corporators_ability(user)
    can :read, Erp::Corporators::Corporator
    
    can :update, Erp::Corporators::Corporator do |corporator|
      true
    end
    
    can :set_active, Erp::Corporators::Corporator do |corporator|
      corporator.is_inactive?
    end
    
    can :set_inactive, Erp::Corporators::Corporator do |corporator|
      corporator.is_active?
    end
    
    can :destroy, Erp::Corporators::Corporator do |corporator|
      corporator.creator == user
    end
  end
end
