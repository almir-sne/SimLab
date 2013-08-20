class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Usuario.new # guest user

    if (user.role == "admin")||(user.role == "coordenador")
      can :manage, :all
      can :see, :banco_de_horas
    elsif user.role == "desenvolvedor"
      can :read,    Usuario
      can :read,    Dia
      can :create,  Dia
      can :destroy, Dia,       :id => true, :id => user.id
      can :update,  Dia,       :id => true, :id => user.id
      can :update,  Usuario,   :id => true, :id => user.id
      can :update,  Atividade, :id => true, :id => user.id
    end


    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
