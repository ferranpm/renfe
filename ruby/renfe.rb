require 'nokogiri'
require 'sqlite3'
require 'net/http'
require 'singleton'
require 'attr_extras'

class Database
  include Singleton

  def connection
    @connection ||= SQLite3::Database.new('database')
  end
end

class Referentiable
  attr_reader_initialize :id, :nombre

  def self.find(id)
    sql = "select nombre from #{table} where id=#{id}"
    row = Database.instance.connection.get_first_row(sql)
    new(id, row[0])
  end
end

class Nucleo < Referentiable
  def self.table
    "nucleos"
  end

  def self.all
    sql = "select id, nombre from nucleos"
    Database.instance.connection.execute(sql).map do |row|
      Nucleo.new(row[0], row[1])
    end
  end

  def estaciones
    sql = <<-SQL
    select id, nombre
    from estaciones
    where nucleo_id=#{id}
    SQL
    Database.instance.connection.execute(sql).map do |row|
      Estacion.new(row[0], row[1])
    end
  end
end

class Estacion < Referentiable
  def self.table
    "estaciones"
  end

  def nucleo
    sql = <<-SQL
      select nucleos.id, nucleos.nombre
      from nucleos, estaciones
      where estaciones.id=#{id}
      and estaciones.nucleo_id=nucleos.id
    SQL
    row = Database.instance.connection.get_first_row(sql)
    Nucleo.new(row[0], row[1])
  end

  def self.all(nucleo)
    sql = <<-SQL
      select id, nombre
      from estaciones
      where nucleo_id=#{nucleo.id}
      order by nombre asc
    SQL
    Database.instance.connection.execute(sql).map do |row|
      Estacion.new(row[0], row[1])
    end
  end
end

class ItinerarioSimple
  attr_accessor_initialize :linea, :hora_origen, :hora_destino
end

class ItinerarioDoble
  attr_accessor_initialize :linea_1, :linea_2, :hora_origen_1, :hora_destino_1, :hora_origen_2, :hora_destino_2
end

class Horario
  attr_reader_initialize :origen, :destino, [ :hora_origen, :hora_destino, :date ]

  def horas
    @horas ||= parse_page
  end

  def hora_origen
    @hora_origen ||= 0
  end

  def hora_destino
    @hora_destino ||= 26
  end

  def date
    @date ||= Date.today
  end

  def page
    @page ||= Nokogiri::HTML(Net::HTTP.get(uri))
  end

  def uri
    URI.parse("http://horarios.renfe.com/#{params}")
  end

  def params
    "cer/hjcer310.jsp?&f1=&df=#{date.strftime("%Y%m%d")}&TXTInfo=&hd=#{hora_destino}&d=#{destino.id}&i=s&cp=NO&nucleo=#{origen.nucleo.id}&o=#{origen.id}&ho=#{hora_origen}"
  end

  def parse_sin_transbordo
    table.css('tr')[1..-1].map do |tr|
      td_list = tr.css('td')
      linea = td_list[0].text.strip
      hora_origen = td_list[2].text.strip
      hora_destino = td_list[3].text.strip
      time = td_list[4].text.strip
      ItinerarioSimple.new(linea, hora_origen, hora_destino)
    end
  end

  def parse_con_transbordo
    prev = nil
    table.xpath('//tr')[4..-1].map do |tr|
      td_list = tr.xpath('td').children
      linea1, hora_origen_1, hora_destino_1 = nil
      if td_list[0].text.strip == "" and prev
        linea1 = prev[0].text.strip
        hora_origen_1 = prev[1].text.strip
        hora_destino_1 = prev[2].text.strip
      else
        linea1 = td_list[0].text.strip
        hora_origen_1 = td_list[1].text.strip
        hora_destino_1 = td_list[2].text.strip
      end
      linea2 = td_list[4].text.strip
      hora_origen_2 = td_list[3].text.strip
      hora_destino_2 = td_list[5].text.strip
      time = td_list[6].text.strip
      prev = td_list unless prev
      ItinerarioDoble.new(linea1, hora_origen_1, hora_destino_1, linea2, hora_origen_2, hora_destino_2)
    end
  end

  def parse_page
    if transbordo
      parse_con_transbordo
    else
      parse_sin_transbordo
    end
  end

  def transbordo
    table.css('tr')[1].children.size > 11
  end

  def table
    page.css('table')[0]
  end
end
