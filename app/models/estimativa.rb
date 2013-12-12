class Estimativa < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :cartao

  def valor_string
    if read_attribute(:valor) == -2.0
      "Infinito"
    elsif read_attribute(:valor) == -1.0
      "?"
    else
      read_attribute(:valor)
    end
  end
end
