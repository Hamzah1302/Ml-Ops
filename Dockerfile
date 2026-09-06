FROM tensorflow/serving:latest

COPY ./output/serving_model /models/cc-model
COPY ./config/prometheus.config /model_config/prometheus.config

ENV MODEL_NAME=cc-model
ENV MONITORING_CONFIG=/model_config/prometheus.config

RUN printf '#!/bin/bash\n\
tensorflow_model_server \\\n\
  --port=8500 \\\n\
  --rest_api_port=${PORT} \\\n\
  --model_name=${MODEL_NAME} \\\n\
  --model_base_path=/models/${MODEL_NAME} \\\n\
  --monitoring_config_file=${MONITORING_CONFIG}\n' > /usr/local/bin/start_tf_serving.sh \
    && chmod +x /usr/local/bin/start_tf_serving.sh

ENTRYPOINT ["/usr/local/bin/start_tf_serving.sh"]
