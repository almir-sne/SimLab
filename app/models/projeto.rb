class Projeto < ActiveRecord::Base
  attr_accessible :data_de_inicio, :descricao, :horas_totais, :name, :valor

  validates :valor,          :numericality =>true

  validates :data_de_inicio, :presence => true

  validates :descricao,      :presence => true

  validates :name,           :presence  => true,
                             :uniqueness => true

  has_many :banco_de_horas
end
