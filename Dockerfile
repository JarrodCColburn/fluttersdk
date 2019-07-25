# Flutter (https://flutter.dev) Development Environment for Linux
# ===============================================================
#
# This environment passes all Linux Flutter Doctor checks and is sufficient
# for building Android applications and running Flutter tests.
# 
# Slimmed down image based on flutter docker image used to build docker sdk 
# and CI (https://github.com/flutter/flutter/blob/master/dev/ci/docker_linux/Dockerfile)
# minuse unnecessary packages (nodejs, ruby, firebase, etc...) 

FROM debian:stretch

ENV LANG en_US.UTF-8

RUN apt-get update -y \
# Install basics
  && apt-get install -y --no-install-recommends \
  git \
  curl \
  zip \
  unzip \
  apt-transport-https \
  ca-certificates \
  gnupg \
  locales \
  libstdc++6 \
  libglu1-mesa \
  build-essential \
  default-jdk-headless \
  xz-utils \
# Clean up image
  && locale-gen en_US ${LANG} \
  && dpkg-reconfigure locales \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* 

ARG ANDROID_SDK_VERSION="4333796"

ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip"
ENV ANDROID_SDK_ROOT="/opt/android"
ENV ANDROID_SDK_ARCHIVE="/tmp/android.zip"
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools/bin"

# Install the Android SDK Dependency.
# Silence warnings when accepting android licenses.
RUN curl --output "${ANDROID_SDK_ARCHIVE}" --url "${ANDROID_SDK_URL}" \
  && unzip -q -d "${ANDROID_SDK_ROOT}" "${ANDROID_SDK_ARCHIVE}" \
  && yes "y" | "${ANDROID_SDK_ROOT}/tools/bin/sdkmanager" "tools" \
  "platform-tools" \
  "extras;android;m2repository" \
  "extras;google;m2repository" \
  "patcher;v4" \ 
  "build-tools;28.0.3" \
  "platforms;android-28" \
# Suppressing output of sdkmanager to keep log size down
# (it prints install progress WAY too often).
  > /dev/null 

ARG FLUTTER_SDK_CHANNEL="stable"
ARG FLUTTER_SDK_VERSION="1.7.8+hotfix.4"

ENV FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v${FLUTTER_SDK_VERSION}-${FLUTTER_SDK_CHANNEL}.tar.xz"
ENV FLUTTER_ROOT="/opt/flutter"
ENV FLUTTER_SDK_ARCHIVE="/tmp/flutter.tar.xz"
ENV PATH="${PATH}:${FLUTTER_HOME}/bin"

ENV DART_SDK="${FLUTTER_ROOT}/bin/cache/dart-sdk"
ENV PUB_CACHE=${FLUTTER_ROOT}/.pub-cache
ENV PATH="${PATH}:${DART_SDK}/bin:${PUB_CACHE}/bin"

RUN  curl --output "${FLUTTER_SDK_ARCHIVE}" --url "${FLUTTER_SDK_URL}" \
  && tar --extract --file="${FLUTTER_SDK_ARCHIVE}" --directory=$(dirname ${FLUTTER_ROOT}) \
  && rm "${FLUTTER_SDK_ARCHIVE}" \
  && mkdir -p ${PUB_CACHE} \
  && ${FLUTTER_ROOT}/bin/flutter doctor 
