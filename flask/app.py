from flask import Flask, request, Response

app = Flask(__name__)


IS_HEALTHY = True

@app.route('/health')
def health():
    if IS_HEALTHY:
        return 'I am Healthy and 200', 200
    else:
        return 'I am unhealthy and 500', 500

@app.route('/reversehealth')
def reverse_health():
    global IS_HEALTHY
    IS_HEALTHY = not IS_HEALTHY
    return f"reversed healthy status to {IS_HEALTHY}", 200
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
    app.run(host= "0.0.0.0", debug=True, port=5000)
