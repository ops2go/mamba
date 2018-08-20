FROM alpine

WORKDIR word

ENV PATH=$PATH:/word

COPY bin/ .

CMD [ "server_linux_amd64" ]


