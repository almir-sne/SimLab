module AtividadesHelper
  def data(mes, ano)
    if mes == 13
      mes = 1
      ano = ano + 1
    elsif mes == 0
      mes = 12
      ano = ano - 1
    end
    return "#{mes};#{ano}"
  end
end
