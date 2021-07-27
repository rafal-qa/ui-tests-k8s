from flask import Flask, Response

app = Flask(__name__)


@app.route("/")
def index():
    return '<h1>Application</h1><p><a href="file.bin">Download</a></p>'


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
