class Estimativa < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :cartao
  belongs_to :planning_card
end
