FROM ubuntu:22.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git python3 python3-pip

# Install the latest open-interpreter
RUN pip install open-interpreter
RUN pip install numpy matplotlib pandas
RUN pip install Flask

WORKDIR /root

# Write out the Flask app directly from the Dockerfile
RUN echo "from flask import Flask" > healthz_app.py && \
    echo "app = Flask(__name__)" >> healthz_app.py && \
    echo "@app.route('/healthz', methods=['GET'])" >> healthz_app.py && \
    echo "def health_check():" >> healthz_app.py && \
    echo "    return \"Success\", 200" >> healthz_app.py && \
    echo "if __name__ == '__main__':" >> healthz_app.py && \
    echo "    app.run(host='0.0.0.0', port=5000)" >> healthz_app.py

# Set the command to run the Flask app
CMD ["python3", "healthz_app.py"]
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=18 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install nodejs -y
    
RUN apt-get install -y npm
RUN apt-get install -y git
RUN git clone https://github.com/aavetis/github-chatgpt-plugin.git /root/github-chatgpt-plugin
RUN cd /root/github-chatgpt-plugin && npm install
RUN cd /root/github-chatgpt-plugin && npm run build
CMD ["npm", "run", "start", "--prefix", "/root/github-chatgpt-plugin"]
