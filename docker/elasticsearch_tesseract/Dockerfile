FROM elasticsearch:7.2.0

RUN bin/elasticsearch-plugin install --batch ingest-attachment && \
    yum-config-manager --add-repo https://download.opensuse.org/repositories/home:/Alexander_Pozdnyakov/CentOS_7/ && \
    rpm --import https://build.opensuse.org/projects/home:Alexander_Pozdnyakov/public_key && \
    yum update -y && \
    yum install tesseract tesseract-langpack-deu tesseract-langpack-eng  -y && \
    yum clean all