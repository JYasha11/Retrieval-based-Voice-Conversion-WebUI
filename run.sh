#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
  # macOS specific env:
  export PYTORCH_ENABLE_MPS_FALLBACK=1
  export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
elif [ "$(uname)" != "Linux" ]; then
  echo "Unsupported operating system."
  exit 1
fi

if [ -d ".venv" ]; then
  echo "Activate venv..."
  . .venv/bin/activate
else
  echo "Create venv..."
  requirements_file="requirements.txt"

  # Check if Python 3 is installed
  if ! command -v python3 >/dev/null 2>&1; then
    echo "Python 3 not found. Please install Python 3 manually."
    exit 1
  fi

  python3 -m venv .venv
  . .venv/bin/activate

  # Upgrade pip and install the required packages from the requirements.txt
  python3 -m pip install --upgrade pip

  # Check if required packages are installed and install them if not
  if [ -f "${requirements_file}" ]; then
    python3 -m pip install -r "${requirements_file}"
  else
    echo "${requirements_file} not found. Please ensure the requirements file with required packages exists."
    exit 1
  fi
fi

# Download models
chmod +x tools/dlmodels.sh
./tools/dlmodels.sh

if [ $? -ne 0 ]; then
  exit 1
fi

# Run the main script
python3 infer-web.py --pycmd python3
