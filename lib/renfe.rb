# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

class Nucleo
  def initialize(id, nombre)
    @id = id
    @nombre = nombre
  end

  attr_reader :id, :nombre

  NUCLEOS = [
    { id: 10, nombre: "Madrid" },
    { id: 20, nombre: "Asturias" },
    { id: 30, nombre: "Sevilla" },
    { id: 31, nombre: "Cádiz" },
    { id: 32, nombre: "Málaga" },
    { id: 40, nombre: "Valencia" },
    { id: 41, nombre: "Murcia/Alicante" },
    { id: 50, nombre: "Barcelona" },
    { id: 60, nombre: "Bilbao" },
    { id: 61, nombre: "San Sebastián" },
    { id: 62, nombre: "Santander" },
    { id: 70, nombre: "Zaragoza" },
  ]

  def self.all
    NUCLEOS.map do |nucleo|
      new(nucleo[:id], nucleo[:nombre])
    end
  end

  def estaciones
    @estaciones ||= options.map do |option|
      Estacion.new(self, option["value"], option.text.strip)
    end
  end

private

  def options
    page.css("select#o option").select { |x| x["value"].match?(/^\d+$/) }
  end

  def page
    Nokogiri::HTML(uri.read)
  end

  def uri
    URI.parse("https://horarios.renfe.com/cer/hjcer300.jsp?NUCLEO=#{id}&CP=NO&I=s")
  end
end

class Estacion
  def initialize(nucleo, id, nombre)
    @nucleo = nucleo
    @id = id
    @nombre = nombre
  end

  attr_reader :nucleo, :id, :nombre
end

class ItinerarioSimple
  def initialize(linea, hora_inicio, hora_fin)
    @linea = linea
    @hora_inicio = hora_inicio
    @hora_fin = hora_fin
  end

  attr_reader :linea, :hora_inicio, :hora_fin
end

class ItinerarioDoble
  def initialize(linea_1, hora_inicio_1, hora_fin_1, linea_2, hora_inicio_2, hora_fin_2)
    @linea_1 = linea_1
    @hora_inicio_1 = hora_inicio_1
    @hora_fin_1 = hora_fin_1
    @linea_2 = linea_2
    @hora_inicio_2 = hora_inicio_2
    @hora_fin_2 = hora_fin_2
  end

  attr_reader :linea_1, :hora_inicio_1, :hora_fin_1, :linea_2, :hora_inicio_2, :hora_fin_2
end

class Horario
  def initialize(origen, destino, hora_inicio: 0, hora_fin: 26, date: Date.today)
    @origen = origen
    @destino = destino
    @hora_inicio = hora_inicio
    @hora_fin = hora_fin
    @date = date
  end

  attr_reader :origen, :destino, :hora_inicio, :hora_fin, :date

  def horas
    @horas ||= parse_page
  end

  def hora_inicio
    @hora_inicio ||= 0
  end

  def hora_fin
    @hora_fin ||= 26
  end

  def date
    @date ||= Date.today
  end

  def itinerarios
    @itinerarios ||= parse_page
  end

private

  def parse_page
    if transbordo?
      parse_con_transbordo
    else
      parse_sin_transbordo
    end
  end

  def transbordo?
    table.css('tr')[0].css('td').size > 5
  end

  def parse_con_transbordo
    prev = nil
    table.css('tr')[4..-1].map do |tr|
      row = tr.css('td').map(&:text).map(&:strip)
      linea_1        = presence(row[0]) || prev && prev[0]
      hora_inicio_1  = presence(row[2]) || prev && prev[2]
      hora_fin_1     = presence(row[3]) || prev && prev[3]
      linea_2        = presence(row[5]) || prev && prev[5]
      hora_inicio_2  = presence(row[4]) || prev && prev[4]
      hora_fin_2     = presence(row[7]) || prev && prev[7]
      prev = row
      ItinerarioDoble.new(linea_1, hora_inicio_1, hora_fin_1, linea_2, hora_inicio_2, hora_fin_2)
    end
  end

  def parse_sin_transbordo
    table.css('tr')[1..-1].map do |tr|
      row = tr.css('td').map(&:text).map(&:strip)
      linea = row[0]
      hora_inicio = row[2]
      hora_fin = row[3]
      ItinerarioSimple.new(linea, hora_inicio, hora_fin)
    end
  end

  def table
    page.css('table')[0]
  end

  def page
    Nokogiri::HTML(uri.read)
  end

  def uri
    URI.parse("https://horarios.renfe.com/#{params}")
  end

  def params
    "cer/hjcer310.jsp?&f1=&df=#{date.strftime("%Y%m%d")}&TXTInfo=&hd=#{hora_fin}&d=#{destino.id}&i=s&cp=NO&nucleo=#{origen.nucleo.id}&o=#{origen.id}&ho=#{hora_inicio}"
  end

  def presence(item)
    item.nil? || item.empty? ? nil : item
  end
end
