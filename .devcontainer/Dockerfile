FROM ruby:2.7.2

COPY ["Gemfile*", "/tmp/"]

RUN gem update --system && \
    bundle install --frozen --gemfile=/tmp/Gemfile

ARG USERNAME
ARG USER_UID
ARG USER_GID

RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

USER $USERNAME