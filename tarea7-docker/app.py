from flask import Flask
import os, socket, datetime

app = Flask(__name__)

@app.route('/')
def home():
    hostname = socket.gethostname()
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return (
        "<html><head><title>DevOps UAX - JJLR</title>"
        "<style>"
        "body{font-family:Arial;background:#1a1a2e;color:#e0e0e0;display:flex;justify-content:center;"
        "align-items:center;min-height:100vh;margin:0}"
        ".card{background:#16213e;padding:40px;border-radius:12px;text-align:center;"
        "border:1px solid #0f3460;max-width:500px}"
        "h1{color:#00d4ff;font-size:2em}"
        ".badge{background:#0f3460;padding:8px 16px;border-radius:20px;margin:8px;display:inline-block}"
        ".green{color:#00ff88}"
        "</style></head>"
        "<body><div class='card'>"
        "<h1>Hello DevOps UAX!</h1>"
        "<p><span class='badge'>Alumno: <b>JJLR</b></span>"
        " <span class='badge'>Tarea 7 - Docker</span></p>"
        "<p><span class='badge'>Hostname: <b>" + hostname + "</b></span></p>"
        "<p><span class='badge'>Time: " + now + "</span></p>"
        "<p class='green'>Contenedor Docker en ejecucion</p>"
        "<p>Flask App desplegada via Jenkins Pipeline</p>"
        "</div></body></html>"
    )

@app.route('/health')
def health():
    return {'status': 'OK', 'service': 'tarea7-jjlr', 'version': '1.0.0'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
