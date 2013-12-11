class PlanningCard < ActiveRecord::Base
  attr_accessible :nome, :valor, :deck_id
  
  belongs_to :deck
end
