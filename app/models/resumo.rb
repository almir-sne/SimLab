class Resumo

# devolve hash com chave os meses, conteudo um vetor de horas_feitas e horas_pretendidas.
# exemplo: {1 => [100, 100], 2 => [100,100], 3 => [50,100]}
  def self.horas_no_mes_de(user)
    meses = (1..12).to_a
    hora_mes = Hash.new

    meses.each do |mes|
      mes_atual = Date.new(Date.today.year, mes, 1)
      proximo_mes = mes_atual.next_month - 1.day

      horas_pretendidas = user.horario_mensal
      horas_feitas = user.banco_de_horas.where{data >> (mes_atual..proximo_mes)}.map{ |bh| bh.horas }
      horas_feitas = horas_feitas.inject{|sum,x| sum + x }

      hora_mes[mes] = [horas_feitas, horas_pretendidas]
    end
    hora_mes
  end

# devolve hash com chave os dias, conteudo a quantidade de horas_feitas
# exemplo: {2013-03-20 => 5, 2013-03-21 => 3, 2013-03-22 => 8}
  def self.horas_no_dia_de(user)
    hora_dia = Hash.new

    for i in -10..0
      hoje = Date.today + i.day
      hora_dia[hoje] = user.banco_de_horas.where{data == hoje}.
        map{|bh| bh.horas}.
          inject{|sum,x| sum + x }
    end

    hora_dia
  end

# devolve hash com chave o nome do projeto e contendo um vetor com horas nesse projeto e valor
# investido no projeto
# exemplo: {labarq => [50000, 10523,57], Atlas => [1500000, 2001523.57]}
  def self.horas_e_investimento_nos_projetos
  	horas = Array.new
    
    projetos = Projeto.all
    usuarios = Usuario.all
    investimento_projeto = Hash.new
    
    projetos.each do |projeto|
      valor_por_projeto = 0
      horas_por_projeto = 0
      
      usuarios.each do |usuario|
        horas_por_usuario = BancoDeHora.find_all_by_projeto_id_and_usuario_id(projeto.id, usuario.id).map{|bh| bh.horas}.inject{|sum,x| sum + x }
        horas_por_projeto += horas_por_usuario
        valor_por_projeto += usuario.valor_da_hora * horas_por_usuario
      end
      investimento_projeto[projeto.name] = [horas_por_projeto, valor_por_projeto]
    end
    investimento_projeto    
  end

end
