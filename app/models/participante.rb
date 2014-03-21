class Participante < ActiveRecord::Base
  belongs_to :reuniao
  belongs_to :usuario
  has_one :projeto, :through => :reuniao
end
