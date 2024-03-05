# frozen_string_literal: true

require "test_helper"
require "renfe"

module Renfe
  describe Renfe do
    it "has a version number" do
      refute_nil ::Renfe::VERSION
    end
  end

  describe Horario do
    it "creates a simple route" do
      barcelona = Nucleo.all.find { |n| n.nombre.match?(/barcelona/i) }
      granollers = barcelona.estaciones.find { |e| e.nombre.match?(/granollers centre/i) }
      sants = barcelona.estaciones.find { |e| e.nombre.match?(/sants/i) }

      horario = Horario.new(granollers, sants)
      times = horario.itinerarios

      refute_empty times
      assert_equal "R2", times.first.linea
    end

    it "creates a route with a transfer" do
      barcelona = Nucleo.all.find { |n| n.nombre.match?(/barcelona/i) }
      granollers = barcelona.estaciones.find { |e| e.nombre.match?(/granollers centre/i) }
      mollet = barcelona.estaciones.find { |e| e.nombre.match?(/canovelles/i) }

      horario = Horario.new(granollers, mollet)
      times = horario.itinerarios

      refute_empty times
      assert_equal "R2", times.first.linea_1
      assert_equal "R3", times.first.linea_2
    end
  end
end
