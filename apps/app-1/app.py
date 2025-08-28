from flask import Flask, render_template
import os

app = Flask(__name__)

@app.route("/")
def home():
    header_text = os.getenv("HEADER_TEXT", "Welcome to Flask!")
    image_url   = os.getenv("IMAGE_URL", "")
    return render_template("index.html", header_text=header_text, image_url=image_url)

@app.route("/health")
def health():
    return {"status": "healthy"}, 200

if __name__ == "__main__":
    # Default to 8080 for local runs; K8s will set PORT via env
    port = int(os.getenv("PORT", "8080"))
    debug = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    app.run(host="0.0.0.0", port=port, debug=debug)
