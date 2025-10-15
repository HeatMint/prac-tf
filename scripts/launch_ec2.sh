#!/bin/bash
# Install requirements
sudo yum install python -y
sudo yum install pip -y
pip install flask
sudo yum install git -y
git clone https://github.com/HeatMint/prac-tf.git
pip install gunicorn
python ./prac-tf/flask/app.py