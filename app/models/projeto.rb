class Projeto < ActiveRecord::Base
  attr_accessible :data_de_inicio, :descricao, :nome, :workon_attributes

  validates :data_de_inicio, :presence => true

  validates :descricao,      :presence => true

  validates :nome,           :presence  => true,
                             :uniqueness => true

  has_many :banco_de_horas

  has_many :atividades
  has_many :usuarios,  :through => :workon
  has_many :workon
  has_many :boards
  accepts_nested_attributes_for :workon, :allow_destroy => true
  accepts_nested_attributes_for :boards, :allow_destroy => true

  def coordenadores
    self.usuarios.includes(:workon).where("workons.coordenador" => true)
  end

  def horas_totais
    atividades.where(:aprovacao => true).sum(:duracao)/3600
  end

  def valor
#    atividades_aprovadas = atividades.where(:aprovacao => true)
#    atividades_aprovadas.map{ |atividade|
#      val_hora = atividade.usuario.contrato_vigente_em(atividade.data).valor_hora
#      (atividade.duracao / 3600) * (val_hora.nil? ? 0 : val_hora )
#    }.sum
    0
  end

end
