module ProjetosHelper

    def acha_usuarios
      nomes_dos_usuarios = Usuario.all.map{ |p| p.nome }
      ids_dos_usuarios   = Usuario.all.map{ |p| p.id   }

      b = Array.new

      for i in 0..(Usuario.count -1)
        a = Array.new
        a << nomes_dos_usuarios[i]
        a << ids_dos_usuarios[i]
        b << a if a != [nil,nil]
      end
      b
    end

end
