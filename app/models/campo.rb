class Campo < ActiveRecord::Base
  belongs_to :projeto
  has_many :dados
  validates_presence_of :projeto_id
  
  def dados_do_usuario(usuario_id)
    dados.find_by(usuario_id: usuario_id).try(:valor)
  end
end
