# coder-custom

基于官方 `coder/coder` 镜像构建的自定义 Docker 镜像，预配置了常用的 Terraform 提供程序和工具。

## 功能特性

- 基于官方 `coder/coder:v2.33.6` 镜像
- 预安装的 Terraform 提供程序：
  - `coder/coder` v2.18.0
  - `kreuzwerker/docker` v4.4.0
  - `hashicorp/kubernetes` v3.2.1
  - `harvester/harvester` v1.8.0
- 已配置 Terraform 离线镜像支持
- 额外工具：`curl`、`unzip`

## 快速开始

### 构建镜像

```bash
docker build -t coder-custom:latest .
```

### 运行容器

```bash
docker run -d -p 8080:8080 coder-custom:latest
```

## 镜像架构

该镜像在官方 Coder 镜像基础上进行了以下扩展：

1. 安装额外的 CLI 工具（`curl`、`unzip`）
2. 创建 Terraform 插件目录结构
3. 下载并安装 Terraform 提供程序
4. 配置 `.terraformrc` 以支持离线提供程序安装

## 自定义提供程序

如需添加或修改 Terraform 提供程序，请编辑 `Dockerfile`：

1. 添加新的 ARG 变量来指定提供程序版本
2. 创建目录结构并下载提供程序

```dockerfile
ARG PROVIDER_VERSION=x.x.x
RUN echo "Adding owner/provider v${PROVIDER_VERSION}" \
    && mkdir -p owner/provider && cd owner/provider \
    && curl -LOs https://github.com/owner/terraform-provider-provider/releases/download/v${PROVIDER_VERSION}/terraform-provider-provider_${PROVIDER_VERSION}_linux_amd64.zip
```

## CI/CD

本项目使用 Renovate Bot + GitHub Actions 实现全自动依赖更新和镜像构建：

- Renovate 自动检测 Terraform provider 和基础镜像的新版本，开 PR 并自动合并
- GitHub Actions 在 master 分支 Dockerfile 变更时自动构建并推送镜像到 `ghcr.io/w0n9/coder`
- 镜像标签格式：`v{基础版本}-{YYYYMMDD}` + `latest`

## 配置参数

### 构建参数

| ARG | 默认值 | 描述 |
|-----|--------|------|
| `CODER_PROVIDER_VERSION` | `2.18.0` | Coder Terraform 提供程序版本 |
| `DOCKER_PROVIDER_VERSION` | `4.4.0` | Docker Terraform 提供程序版本 |
| `KUBERNETES_PROVIDER_VERSION` | `3.1.0` | Kubernetes Terraform 提供程序版本 |
| `HARVESTER_PROVIDER_VERSION` | `1.8.0` | Harvester Terraform 提供程序版本 |

### 自定义版本示例

```bash
docker build \
  --build-arg CODER_PROVIDER_VERSION=2.9.0 \
  --build-arg DOCKER_PROVIDER_VERSION=3.7.0 \
  -t coder-custom:latest .
```

## 版本说明

镜像标签格式为 `v<Coder版本>-<YYYYMMDD>`。例如，`v2.23.2-20260529` 表示：
- Coder 基础镜像版本：2.23.2
- 构建日期：2026-05-29

## 许可证

MIT
