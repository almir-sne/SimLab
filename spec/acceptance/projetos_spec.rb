require 'spec_helper'

feature Projeto do
	include Helpers

	describe "novo" do
		scenario "deveria poder ser criado" do
		  visit new_projeto_path
		  fill_in "Nome",  :with => "teste_cria_novo_projeto"
		  fill_in "Descrição", :with => "Novo projeto"
		  fill_in "Valor", :with => "10"
		  click_button I18n.t("helpers.submit.create", :model => I18n.t("activerecord.models.project"))
		  page.should have_content(I18n.t("projetos.create.sucess", :model => "Projeto"))
		  page.should have_content("teste_cria_novo_projeto")
		end
	end

	describe "projeto existente" do
		scenario "deveria poder ser editado" do
		  visit edit_projeto_path(@project)
		  fill_in "Nome", :with => "Teste"
		  click_button I18n.t("helpers.submit.update", :model => I18n.t("activerecord.models.project"))
		  page.should have_content(I18n.t("projetos.update.sucess"))
		end

		scenario "não deveria ser acessivel sem login" do
		  click_link "Sair"
		  visit projeto_path(@project)
		  page.should have_content(I18n.t("devise.failure.unauthenticated"))
		end

		before(:each) do
		  @project = FactoryGirl.create(:projeto)
		end
	end

	before(:each) do
	  desenvolvedor_faz_login
	end
end
