FROM ruby:2.7.2

COPY ["Gemfile*", "/tmp/"]

RUN gem update --system && \
    bundle config set --local frozen 'true' && \
    bundle install --gemfile=/tmp/Gemfile

ARG USERNAME
ARG USER_UID
ARG USER_GID

RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
#     && apt-get update \
#     && apt-get install -y sudo \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME