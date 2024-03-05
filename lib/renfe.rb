# frozen_string_literal: true

require "nokogiri"
require "open-uri"
require_relative "renfe/version"

module Renfe
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
    ].freeze

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

  class Horario
    def initialize(origen, destino, hora_inicio: 0, hora_fin: 26, date: Date.today)
      @origen = origen
      @destino = destino
      @hora_inicio = hora_inicio
      @hora_fin = hora_fin
      @date = date
    end

    attr_reader :origen, :destino

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
      table.at_css("tr").css("td").size > 5
    end

    def parse_con_transbordo
      prev = nil
      table.css("tr")[4..].map do |tr|
        row = tr.css("td").map(&:text).map(&:strip)

        build_itinerario_doble(row, prev)
      end
    end

    def build_itinerario_doble(row, prev)
      ItinerarioDoble.new(
        row[0] || prev[0],
        row[2] || prev[2],
        row[3] || prev[3],
        row[5] || prev[5],
        row[4] || prev[4],
        row[7] || prev[7],
      )
    end

    def parse_sin_transbordo
      table.css("tr")[1..].map do |tr|
        row = tr.css("td").map(&:text).map(&:strip)

        build_itinerario_simple(row)
      end
    end

    def build_itinerario_simple(row)
      ItinerarioSimple.new(row[0], row[2], row[3])
    end

    def table
      page.at_css("table#tabla")
    end

    def page
      Nokogiri::HTML(uri.read)
    end

    def uri
      uri = URI.parse("https://horarios.renfe.com/cer/hjcer310.jsp")
      uri.query = URI.encode_www_form(params)
      uri
    end

    def params
      {
        "f1" => "",
        "TXTInfo" => "",
        "i" => "s",
        "cp" => "NO",
        "nucleo" => origen.nucleo.id, "o" => origen.id, "d" => destino.id,
        "df" => date.strftime("%Y%m%d"), "ho" => hora_inicio, "hd" => hora_fin,
      }
    end
  end

  Estacion = Struct.new(:nucleo, :id, :nombre)
  ItinerarioSimple = Struct.new(:linea, :hora_inicio, :hora_fin)
  ItinerarioDoble = Struct.new(:linea_1, :hora_inicio_1, :hora_fin_1, :linea_2, :hora_inicio_2, :hora_fin_2)
end
