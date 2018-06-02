require 'nokogiri'
require 'sqlite3'
require 'net/http'
require 'attr_extras'

Object.class_eval do
  unless method_defined?(:presence)
    define_method(:presence) do
      nil? || empty? ? nil : self
    end
  end
end

class Database
  def self.connection
    @@connection ||= SQLite3::Database.new(database_path)
  end

  def self.database_path
    @@database_path ||= File.join(File.dirname(__FILE__), 'database')
  end
end

class Referentiable
  attr_reader_initialize :id, :nombre

  def self.find(id)
    sql = "select nombre from #{table} where id=#{id}"
    row = Database.connection.get_first_row(sql)
    new(id, row[0])
  end
end

class Nucleo < Referentiable
  def self.table
    "nucleos"
  end

  def self.all
    sql = "select id, nombre from nucleos"
    Database.connection.execute(sql).map do |row|
      Nucleo.new(row[0], row[1])
    end
  end

  def estaciones
    sql = <<-SQL
    select id, nombre
    from estaciones
    where nucleo_id=#{id}
    SQL
    Database.connection.execute(sql).map do |row|
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
    row = Database.connection.get_first_row(sql)
    Nucleo.new(row[0], row[1])
  end

  def self.all(nucleo)
    sql = <<-SQL
      select id, nombre
      from estaciones
      where nucleo_id=#{nucleo.id}
      order by nombre asc
    SQL
    Database.connection.execute(sql).map do |row|
      Estacion.new(row[0], row[1])
    end
  end
end

class ItinerarioSimple
  attr_accessor_initialize :linea, :hora_inicio, :hora_fin
end

class ItinerarioDoble
  attr_accessor_initialize :linea_1, :hora_inicio_1, :hora_fin_1, :linea_2, :hora_inicio_2, :hora_fin_2
end

class Horario
  attr_reader_initialize :origen, :destino, [ :hora_inicio, :hora_fin, :date ]

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

  def page
    @page ||= Nokogiri::HTML(Net::HTTP.get(uri))
  end

  def uri
    URI.parse("http://horarios.renfe.com/#{params}")
  end

  def params
    "cer/hjcer310.jsp?&f1=&df=#{date.strftime("%Y%m%d")}&TXTInfo=&hd=#{hora_fin}&d=#{destino.id}&i=s&cp=NO&nucleo=#{origen.nucleo.id}&o=#{origen.id}&ho=#{hora_inicio}"
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

  def parse_con_transbordo
    prev = nil
    table.css('tr')[4..-1].map do |tr|
      row = tr.css('td').map(&:text).map(&:strip)
      linea_1        = row[0].presence || prev && prev[0]
      hora_inicio_1  = row[2].presence || prev && prev[2]
      hora_fin_1     = row[3].presence || prev && prev[3]
      linea_2        = row[5].presence || prev && prev[5]
      hora_inicio_2  = row[4].presence || prev && prev[4]
      hora_fin_2     = row[7].presence || prev && prev[7]
      prev = row
      ItinerarioDoble.new(linea_1, hora_inicio_1, hora_fin_1, linea_2, hora_inicio_2, hora_fin_2)
    end
  end

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

  def table
    page.css('table')[0]
  end
end
