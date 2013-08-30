class Projeto < ActiveRecord::Base
  attr_accessible :data_de_inicio, :descricao, :horas_totais, :nome, :valor, :workon_attributes

  validates :valor,          :numericality =>true

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

end
