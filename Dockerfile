FROM ubuntu:14.04
CMD ["echo", "Intentional vuln test"]
LABEL dummy="build-001"
RUN echo "noop"
RUN echo "Hello"
RUN echo "JAIM"
