FROM tensorflow/serving:latest

COPY ./output/serving_model /models/cc-model
COPY ./config /model_config

ENV MODEL_NAME=cc-model
ENV MONITORING_CONFIG=/model_config/prometheus.config

CMD tensorflow_model_server \
    --rest_api_port=$PORT \
    --model_name=${MODEL_NAME} \
    --model_base_path=/models/${MODEL_NAME} \
    --monitoring_config_file=${MONITORING_CONFIG}