require 'spec_helper'

feature "Banco de horas" do
  scenario "cria novo banco de horas" do
    visit new_banco_de_hora_path
  end
end
