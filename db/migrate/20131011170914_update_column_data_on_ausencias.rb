class UpdateColumnDataOnAusencias < ActiveRecord::Migration
  def up
    Ausencia.all.each do |a|
        a.data = Date.new(a.mes.ano, a.mes.numero, a.dia)
        a.save
    end
  end

  def down
    Ausencia.all.each do |a|
      a.data = nil
      a.save
    end
  end
end
