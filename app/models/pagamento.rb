class Pagamento < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :criador, :class_name => "Usuario"
  has_one    :anexo

  scope :periodos, lambda { |range| where(data: range)}
  scope :ano, lambda { |value| where(['extract(year from pagamentos.data) = ?', value]) if value > 0 }
  scope :mes, lambda { |value| where(['extract(month from pagamentos.data) = ?', value]) if value > 0 }
  scope :dia, lambda { |value| where(['extract(day from pagamentos.data) = ?', value]) if value > 0 }
  scope :usuario, lambda { |value| where(usuario_id: value) unless value.blank? }
end
