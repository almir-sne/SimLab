module ProjetosHelper
  def acha_usuarios
    Usuario.all(:order => :nome).collect { |p| [p.nome, p.id]  }
  end
end
