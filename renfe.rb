require 'nokogiri'
require 'sqlite3'
require 'net/http'

$db = SQLite3::Database.new('database')

class Referentiable
    attr_reader :id, :nombre
    def initialize id, nombre
        @id, @nombre = id, nombre
    end

    def dict
        {
            :id => @id,
            :nombre => @nombre
        }
    end

    def to_s
        "#{id}: #{nombre}"
    end
end

class Nucleo < Referentiable
    def self.get_by_id id
        row = $db.execute("SELECT nombre FROM nucleos WHERE id=#{id};")
        Nucleo.new(id, row[0])
    end

    def self.get_nucleos
        nucleos = []
        $db.execute("SELECT id, nombre FROM nucleos") do |row|
            nucleos.push(Nucleo.new(row[0], row[1]))
        end
        nucleos
    end
end

class Estacion < Referentiable
    def nucleo
        row = $db.get_first_row("SELECT n.id, n.nombre FROM nucleos n, estaciones e WHERE e.id=#{id} AND e.nucleo_id=n.id;")
        Nucleo.new(row[0], row[1])
    end

    def self.get_by_id id
        row = $db.execute("SELECT nombre FROM estaciones WHERE id=#{id};")
        Estacion.new(id, row[0])
    end

    def self.get_estaciones nucleo
        estaciones = []
        $db.execute("SELECT id, nombre FROM estaciones WHERE nucleo_id=#{nucleo.id} ORDER BY nombre ASC;") do |row|
            estaciones.push(Estacion.new(row[0], row[1]))
        end
        estaciones
    end
end

class ItinerarioSimple
    attr_accessor :linea, :ho, :hd
    def initialize linea, ho, hd
        @linea, @ho, @hd = linea, ho, hd
    end
end

class ItinerarioDoble
    attr_accessor :linea1, :ho1, :hd1, :linea2, :ho2, :hd2
    def initialize linea1, ho1, hd1, linea2, ho2, hd2
        @linea1, @ho1, @hd1, @linea2, @ho2, @hd2 = linea1, ho1, hd1, linea2, ho2, hd2
    end
end

class Horario
    attr_accessor :origen, :destino, :ho, :hd, :date
    attr_accessor :horas, :transbordo
    def initialize origen, destino, ho=00, hd=26, date="20141211"
        @origen, @destino, @ho, @hd, @date = origen, destino, ho, hd, date
        @horas = []
        @transbordo = false
        parse_page get_page
    end

    def get_page
        url = "http://horarios.renfe.com"
        params = "/cer/hjcer310.jsp?&f1=&df=#{date}&TXTInfo=&hd=#{hd}&d=#{destino.id}&i=s&cp=NO&nucleo=#{origen.nucleo.id}&o=#{origen.id}&ho=#{ho}"

        Nokogiri::HTML(Net::HTTP.get_response(URI.parse(url + params)).body)
    end

    def parse_sin_transbordo table
        table.xpath('//tr')[2..-1].each do |tr|
            td_list = tr.xpath('td').children
            linea = td_list[0].text.strip # linea
            horig = td_list[1].text.strip # hd
            hdest = td_list[2].text.strip # ho
            time  = td_list[3].text.strip # time
            @horas << ItinerarioSimple.new(linea, horig, hdest)
        end
    end

    def parse_con_transbordo table
        prev = nil
        table.xpath('//tr')[4..-1].each do |tr|
            td_list = tr.xpath('td').children
            linea1, horig1, hdest1 = nil
            if td_list[0].text.strip == "" and prev
                linea1 = prev[0].text.strip
                horig1 = prev[1].text.strip
                hdest1 = prev[2].text.strip
            else
                linea1 = td_list[0].text.strip
                horig1 = td_list[1].text.strip
                hdest1 = td_list[2].text.strip
            end
            linea2 = td_list[4].text.strip
            horig2 = td_list[3].text.strip
            hdest2 = td_list[5].text.strip
            time = td_list[6].text.strip
            @horas << ItinerarioDoble.new(linea1, horig1, hdest1, linea2, horig2, hdest2)
            prev = td_list if not prev
        end
    end

    def parse_page page
        table = page.xpath('//table')[0]
        @transbordo = table.xpath('//tr')[1].children.size > 11
        if transbordo
            parse_con_transbordo table
        else
            parse_sin_transbordo table
        end
    end

    def to_s
        str = ""
        @horas.each do |h|
            if @transbordo
                str << "Linea1: #{h.linea1} Horig1: #{h.ho1} Hdest1: #{h.hd1} Linea2: #{h.linea2} Horig2: #{h.ho2} Hdest2: #{h.hd2}\n"
            else
                str << "Linea: #{h.linea} Horig: #{h.ho} Hdest: #{h.hd}\n"
            end
        end
        str
    end

    private :get_page, :parse_sin_transbordo, :parse_con_transbordo, :parse_page
end
