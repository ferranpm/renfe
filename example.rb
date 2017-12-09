require_relative './lib/renfe.rb'

badalona = Estacion.find 79404
vilafranca = Estacion.find 72204
premia = Estacion.find 79409

def print_horario(horario)
  puts horario.horas.size
  if horario.transbordo?
    horario.horas.each do |line|
      puts "linea_1: #{line.linea_1}\tlinea_2: #{line.linea_2}\thora_origen_1: #{line.hora_origen_1}\thora_destino_1: #{line.hora_destino_1}\thora_origen_2: #{line.hora_origen_2}\thora_destino_2: #{line.hora_destino_2}"
    end
  else
    horario.horas.each do |line|
      puts "linea: #{line.linea}\thora_origen: #{line.hora_origen}\thora_destino: #{line.hora_destino}"
    end
  end
end

print_horario(Horario.new(badalona, premia))
# print_horario(Horario.new(vilafranca, premia))
