module BancoDeHorasHelper

  def acha_projetos()
  raise "asd"
    nomes_de_projetos = Projeto.all.map{ |p| p.nome }
    ids_de_projetos   = Projeto.all.map{ |p| p.id   }

    b = Array.new

    for i in 0..(Projeto.count - 1)
      a = Array.new
      a << nomes_de_projetos[i]
      a << ids_de_projetos[i]
      b << a
    end
    b
  end

end
