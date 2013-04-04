class Mes < ActiveRecord::Base
  attr_accessible :ano, :horas_contratadas, :numero, :user_id, :valor_hora

  has_many :dias

  belongs_to :usuario

end
