FROM python:3.9
RUN pip3 install pre-commit==2.6.0
ARG $COMPONENT
WORKDIR /usr/src
COPY .util/lint/python /usr/src
COPY $COMPONENT /usr/src/app

CMD ["/usr/src/run_lint_python.sh"]
