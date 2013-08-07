class DiasController < ApplicationController
  before_filter :authenticate_usuario!

  def create
    dia = Dia.find_by_id(params[:dia_id])
    if dia.blank?
      dia = Dia.new
    end
    dia_success = dia.update_attributes(
      :numero => params[:dia][:numero],
      :entrada => convert_date(params[:dia], "entrada"),
      :saida => convert_date(params[:dia], "saida"),
      :intervalo => (params[:dia]["intervalo_time(4i)"].to_i * 3600 +  params[:dia]["intervalo_time(5i)"].to_i * 60),
      :mes_id => params[:mes],
      :usuario_id => params[:user_id]
    )
    atividades_success = true
    params[:dia][:atividades_attributes].each do |lixo, atividade_attr|
      atividade = Atividade.find_by_id atividade_attr[:id].to_i
      if atividade.blank?
        atividade = Atividade.new
      end
      if atividade_attr["_destroy"] == "1" and !atividade.blank?
        atividade.destroy()
      else
        atividades_success = atividades_success and atividade.update_attributes(
          :duracao => atividade_attr["horas(4i)"].to_i * 3600 +  atividade_attr["horas(5i)"].to_i * 60,
          :observacao => atividade_attr["observacao"],
          :projeto_id => atividade_attr["projeto_id"],
          :dia_id => dia.id,
          :mes_id => params[:mes],
          :usuario_id => params[:user_id]
        )
      end
    end
    if dia_success and atividades_success
      flash[:notice] = I18n.t("banco_de_horas.create.sucess")
    else
      flash[:error] = I18n.t("banco_de_horas.create.failure")
    end
    redirect_to banco_de_horas_path(:month => Mes.find(params[:mes]).numero, :year => params[:ano], :user => params[:user_id])
  end

  def destroy
    dia = Dia.find params[:id]
    dia.destroy
    redirect_to :back
  end

  private

  def convert_date(hash, date_symbol_or_string)
    attribute = date_symbol_or_string.to_s
    return DateTime.new(
      hash[attribute + '(1i)'].to_i,
      hash[attribute + '(2i)'].to_i,
      hash[attribute + '(3i)'].to_i,
      hash[attribute + '(4i)'].to_i,
      hash[attribute + '(5i)'].to_i,
      0 )
  end
end
