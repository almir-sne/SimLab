class Pagamento < ActiveRecord::Base
  attr_accessible :data, :fonte, :motivo, :usuario_id, :valor
  belongs_to :mes
  belongs_to :usuario
  belongs_to :criador, :class_name => "Usuario"

  scope :periodos, lambda { |range| where(data: range)}
  scope :ano, lambda { |value| where(['extract(year from pagamentos.data) = ?', value]) if value > 0 }
  scope :mes, lambda { |value| where(['extract(month from pagamentos.data) = ?', value]) if value > 0 }
  scope :dia, lambda { |value| where(['extract(day from pagamentos.data) = ?', value]) if value > 0 }
  scope :usuario, lambda { |value| where(usuario_id: value) unless value.blank? }
end
