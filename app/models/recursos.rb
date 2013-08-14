class Recursos < ActiveRecord::Base
  attr_accessible :mes_id, :origem_id, :valor

  belongs_to :origem
  belongs_to :mes
end
