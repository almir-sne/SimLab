require 'test_helper'

class BancoDeHorasControllerTest < ActionController::TestCase
  setup do
    @banco_de_hora = banco_de_horas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:banco_de_horas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create banco_de_hora" do
    assert_difference('BancoDeHora.count') do
      post :create, banco_de_hora: { data: @banco_de_hora.data, horas: @banco_de_hora.horas, observacao: @banco_de_hora.observacao, projeto_id: @banco_de_hora.projeto_id, usuario_id: @banco_de_hora.usuario_id }
    end

    assert_redirected_to banco_de_hora_path(assigns(:banco_de_hora))
  end

  test "should show banco_de_hora" do
    get :show, id: @banco_de_hora
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @banco_de_hora
    assert_response :success
  end

  test "should update banco_de_hora" do
    put :update, id: @banco_de_hora, banco_de_hora: { data: @banco_de_hora.data, horas: @banco_de_hora.horas, observacao: @banco_de_hora.observacao, projeto_id: @banco_de_hora.projeto_id, usuario_id: @banco_de_hora.usuario_id }
    assert_redirected_to banco_de_hora_path(assigns(:banco_de_hora))
  end

  test "should destroy banco_de_hora" do
    assert_difference('BancoDeHora.count', -1) do
      delete :destroy, id: @banco_de_hora
    end

    assert_redirected_to banco_de_horas_path
  end
end
