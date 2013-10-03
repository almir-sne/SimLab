class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Usuario.new # guest user

    if user.role == "admin"
      can :manage, :all
      can :manage, :banco_de_horas
    elsif user.role == "diretor"
      can :manage, Projeto
      can :manage, Ausencia
      can [:create, :custom_create, :read ], Usuario
      can [:update, :see], Usuario, :id => true, :id => user.id
      unless user.projetos_coordenados.blank?
        can :update, :validations
      end
    elsif user.role == "usuario normal"
      unless user.projetos_coordenados.blank?
        can :update, :validations
      end
      can :read,    Usuario
      can [:read,:create], Dia
      can [:destroy,:update], Dia, :id => true, :id => user.id
      can :update,  [Usuario, Atividade],   :id => true, :id => user.id
      can [:meses, :listar], Pagamento
      can [:destroy, :create], Ausencia
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
