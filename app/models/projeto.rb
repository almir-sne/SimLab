class Projeto < ActiveRecord::Base
  attr_accessible :data_de_inicio, :descricao, :horas_totais, :name, :valor

  validates_presence_of :name, :data_de_inicio

  has_many :banco_de_horas
end
