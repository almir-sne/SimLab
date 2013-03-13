class Resumo < ActiveRecord::Base

    def self.horas_no_mes(user)
      meses = (1..12).to_a
      hora_mes = Hash.new

      meses.each do |mes|
        mes_atual = Date.new(Date.today.year, mes, 1)
        proximo_mes = mes_atual.next_month - 1.day

        horas_pretendidas = Usuario.find(user.id).horario_mensal
        horas_feitas = BancoDeHora.find_all_by_usuario_id_and_data(user.id, mes_atual..proximo_mes).map{ |bh| bh.horas }
        horas_feitas = horas_feitas.inject{|sum,x| sum + x }

        hora_mes[mes] = [horas_feitas, horas_pretendidas]
      end
      hora_mes
    end



    private



end
