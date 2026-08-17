#!/bin/bash
# 全面清理 Debian 系统空间占用

set -e

BACKUP_DIR="backup-journal"
TIMESTAMP=$(date +%F.%H-%M-%S)
LOG_BACKUP="$BACKUP_DIR/journal-$TIMESTAMP.tar.gz"

# 检查是否以 root 权限运行
if [[ $EUID -ne 0 ]]; then
   echo "请使用 root 权限或 sudo 运行此脚本"
   exit 1
fi

echo "正在备份日志..."
mkdir -p "$BACKUP_DIR"
if ! tar --warning=no-file-changed -czf "$LOG_BACKUP" /var/log/journal; then
    read -p "日志备份失败，是否继续执行清理操作？(y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "操作已取消。"
        exit 0
    fi
fi

# 1. 清理 APT 缓存
echo "正在清理过期和冗余的软件包..."
apt-get autoremove -y   # 删除不再需要的依赖包
apt-get autoclean -y    # 删除旧版本的软件安装包
apt-get clean           # 删除 /var/cache/apt/archives/ 下的所有包

# 2. 清理日志文件 (保留最近 3 天)
if command -v journalctl >/dev/null; then
    echo "正在压缩并清理 systemd 日志..."
    journalctl --vacuum-time=3d
fi

# 3. 清理旧的核心文件 (如果有的话)
echo "正在清理旧的内核文件..."
# 注意：这通常由 autoremove 处理，但手动触发更稳妥
dpkg --list | grep 'linux-image' | awk '{ print $2 }' | sort -V \
    | sed -n '/'"$(uname -r | sed "s/-.*//")"'/q;p' \
    | xargs apt-get -y purge

# 4. 清理临时目录
echo "正在清理 /tmp 目录..."
find /tmp -type f -atime +2 -delete

# 5. 清理用户缓存 (针对所有用户)
echo "正在清理用户级缓存..."
rm -rf /home/*/.cache/*
rm -rf /root/.cache/*

# 6. 清理 Docker (如果安装了 Docker)
if command -v docker >/dev/null; then
    echo "检测到 Docker，正在清理未使用的镜像和容器..."
    docker system prune -af --volumes
    docker builder prune -af
fi

echo "--- 磁盘清理完成！ ---"
df -h