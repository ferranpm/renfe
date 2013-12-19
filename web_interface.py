import flask
import renfe
import json

app = flask.Flask(__name__)

@app.route("/nucleos")
def get_nucleos():
    nucleos = renfe.Nucleo.get_nucleos()
    return json.dumps([n.to_dict() for n in nucleos])

@app.route("/estaciones")
def get_estaciones():
    nucleo_id = flask.request.args.get("n")
    if not nucleo_id: return "No hay nucleo (arg: n)"
    nucleo = renfe.Nucleo.get_by_id(nucleo_id)
    estaciones = renfe.Estacion.get_estaciones(nucleo)
    return json.dumps([e.to_dict() for e in estaciones])

@app.route("/horario")
def get_horario():
    orig = flask.request.args.get("o")
    dest = flask.request.args.get("d")
    if not orig or not dest: return "Falta alguna estacion..."
    return 'asdf'

if __name__ == "__main__":
    app.run(debug=True)
