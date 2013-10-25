class Pagamento < ActiveRecord::Base
  attr_accessible :data, :fonte, :mes_id, :motivo, :usuario_id, :valor
  belongs_to :mes
  belongs_to :usuario
  belongs_to :criador, :class_name => "Usuario"

  scope :periodos, lambda { |range| where(data: range)}
end
