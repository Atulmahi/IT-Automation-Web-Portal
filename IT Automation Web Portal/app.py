from flask import Flask, jsonify, render_template
import subprocess
import os

app = Flask(__name__)


# -----------------------------
# FUNCTION TO RUN POWERSHELL SCRIPT
# -----------------------------
def run_powershell(script_name):
    try:
        script_path = os.path.abspath(f"./scripts/{script_name}")

        subprocess.Popen([
            "powershell.exe",
            "-ExecutionPolicy", "Bypass",
            "-File", script_path
        ], creationflags=subprocess.CREATE_NO_WINDOW)

        return True
    except Exception as e:
        return str(e)


# -----------------------------
# HOME PAGE
# -----------------------------
@app.route("/")
def home():
    return render_template("index.html")


# -----------------------------
# UNIVERSAL TASK HANDLER
# -----------------------------
@app.route("/run/<task>")
def run_task(task):

    scripts = {
        "install_printer": "install_printer.ps1",
        "fast_system": "fast_system.ps1",
        "cleanmgr": "cleanmgr.ps1"
    }

    if task not in scripts:
        return jsonify({"message": "Invalid Task"}), 400

    result = run_powershell(scripts[task])

    if result is True:
        return jsonify({"message": f"{task.replace('_', ' ').title()} executed successfully!"})
    else:
        return jsonify({"message": "Error: " + result}), 500

@app.route("/run/cleanmgr")
def run_cleanmgr():
    try:
        subprocess.Popen([
            "powershell.exe",
            "-ExecutionPolicy", "Bypass",
            "-File", "./scripts/cleanmgr.ps1"
        ])
        return jsonify({"message": "Windows Optimization + Cleanmgr started!"})
    except Exception as e:
        return jsonify({"message": "Error: " + str(e)})

# -----------------------------
subprocess.Popen(["schtasks", "/run", "/tn", "CleanMgrTask"])

# MAIN RUN
# -----------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
