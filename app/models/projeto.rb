class Projeto < ActiveRecord::Base
  attr_accessible :data_de_inicio, :descricao, :horas_totais, :nome, :valor

  validates :valor,          :numericality =>true

  validates :data_de_inicio, :presence => true

  validates :descricao,      :presence => true

  validates :nome,           :presence  => true,
                             :uniqueness => true

  has_many :banco_de_horas

  has_many :atividades
  has_many :usuarios,  :through => :workon
  has_many :workon

  accepts_nested_attributes_for :workon, :allow_destroy => true

end
