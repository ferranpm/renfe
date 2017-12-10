require_relative './lib/renfe.rb'

badalona = Estacion.find 79404
vilafranca = Estacion.find 72204
premia = Estacion.find 79409

def print_horario(horario)
  puts horario.horas.size
  if horario.transbordo?
    horario.horas.each do |line|
      puts "linea_1: #{line.linea_1}\tlinea_2: #{line.linea_2}\thora_inicio_1: #{line.hora_inicio_1}\thora_fin_1: #{line.hora_fin_1}\thora_inicio_2: #{line.hora_inicio_2}\thora_fin_2: #{line.hora_fin_2}"
    end
  else
    horario.horas.each do |line|
      puts "linea: #{line.linea}\thora_inicio: #{line.hora_inicio}\thora_fin: #{line.hora_fin}"
    end
  end
end

print_horario(Horario.new(badalona, premia))
# print_horario(Horario.new(vilafranca, premia))
