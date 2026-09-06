FROM tensorflow/serving:latest

COPY ./output/serving_model /models/cc-model

ENV MODEL_NAME=cc-model

CMD tensorflow_model_server \
    --rest_api_port=$PORT \
    --model_name=${MODEL_NAME} \
    --model_base_path=/models/${MODEL_NAME}
