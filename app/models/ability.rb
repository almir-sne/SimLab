class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Usuario.new # guest user

    if user.role == "admin"
      can :manage, :all
    elsif user.role == "diretor"
      can :manage, Projeto
      can :manage, Cartao
      can :manage, Ausencia
      can :manage, Atividade
      can [:create, :custom_create, :read ], Usuario
      can [:update, :see], Usuario, :id => true, :id => user.id
      unless user.projetos_coordenados.blank?
        can :update, :validations
      end
    elsif user.role == "usuario normal"
      unless user.projetos_coordenados.blank?
        can :update, :validations
      end
      can :create, Projeto
      can [:edit, :read], Projeto, :workons => {:usuario_id => user.id}
      can :manage, Projeto, :workons => {:usuario_id => user.id, :permissao => {:nome => "admin"}}
      can :update, Projeto, :workons => {:usuario_id => user.id, :permissao => {:nome => "coordenador"}}
      can :download,            Anexo, :usuario_id => user.id
      can :read,                Usuario, :usuario_id => user.id
      can [:read,:create],      Dia, :usuario_id => user.id
      can [:destroy,:update],   Dia, :id => true, :usuario_id => user.id
      can :update,              Usuario,   :id => true, :id => user.id
      can [:validacao, :ajax_form, :aprovar], Atividade
      can [:update, :destroy],  Atividade, :usuario_id => user.id
      can :alt_role, Usuario
      can [:periodos, :listar], Pagamento, :usuario_id => user.id
      can [:destroy, :create, :show, :edit],  Ausencia
      can [:index, :edit, :update, :find_or_create], Cartao
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
