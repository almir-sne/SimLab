require 'spec_helper'

feature "Ausencias" do
	include Helpers

	describe "nova" do
	  scenario "sem justificativa" do
      desenvolvedor_faz_login
      visit new_ausencia_path(:data => "2013-01-02", :tipo => "p")
      click_button "Ok"
    end

    scenario "com justificativa" do
      desenvolvedor_faz_login
      visit new_ausencia_path(:data => "2013-01-02", :tipo => "p")
      fill_in :ausencia_justificativa, :with => "Isso é um teste"
      click_button "Ok"
    end
  end
end      
