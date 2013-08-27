# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'holidays'
require 'holidays/br'
class Date
  def dias_uteis_restantes(diff= 0, regiao='br')
    final_do_mes = self.at_end_of_month
    dias_uteis = 0
    d = self
    if d.month != Date.today.month
      return 0
    end
    while (d != final_do_mes + 1.day)
      if (!d.sunday? and !d.saturday? and !d.holiday?(regiao))
        dias_uteis+= 1
      end
      d = d.next
    end
    return dias_uteis-diff
  end
end
