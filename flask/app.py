from flask import Flask, request, Response

app = Flask(__name__)

@app.route('/', defaults={'subpath': ''})
@app.route('/<path:subpath>')
def catch_all(subpath):
    # If the path (without leading slash) is an integer (supports optional leading -)
    if subpath and subpath.lstrip('-').isdigit():
        n = int(subpath)
        text = f"{n} + 1 is {n + 1}"
    else:
        # Echo the requested path (include leading slash for clarity)
        path = '/' + subpath
        text = path
    return Response(text, mimetype='text/plain')

if __name__ == '__main__':
    app.run(debug=True)
