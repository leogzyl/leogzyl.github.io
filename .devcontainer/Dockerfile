FROM ruby:2.7.2

ARG USERNAME
ARG USER_UID
ARG USER_GID

WORKDIR /app

# Create the user
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown $USER_UID:$USER_GID /app

USER $USERNAME