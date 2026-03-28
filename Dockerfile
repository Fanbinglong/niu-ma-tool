# 使用官方Flutter镜像
FROM cirrusci/flutter:stable

# 设置工作目录
WORKDIR /app

# 复制项目文件到容器中
COPY pubspec.yaml pubspec.lock ./
COPY lib/ ./lib/
COPY android/ ./android/

# 安装依赖
RUN flutter pub get

# 构建APK
RUN flutter build apk --release

# 设置默认命令（可选）
CMD ["ls", "-la", "build/app/outputs/flutter-apk/"]