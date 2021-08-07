from flask import Flask, Response, render_template

app = Flask(__name__)


@app.route("/")
def index():
    return render_template("index.html")


# Smoke test, check dependencies, etc.
@app.route('/startup')
def startup():
    return 'OK'


# Short, simple check, eg. check if Flask is live
@app.route('/live')
def live():
    return 'OK'


@app.route("/file.bin")
def download():
    return Response("file contents", mimetype="application/octet-stream")
