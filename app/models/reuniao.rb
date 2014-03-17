class Reuniao < ActiveRecord::Base
  belongs_to :criador, class_name: "Usuario"
  belongs_to :projeto
end
