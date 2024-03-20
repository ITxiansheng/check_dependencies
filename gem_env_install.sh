#!/bin/bash
# 查找gem可执行文件目录
GEM_BIN_DIR=$(gem env | grep -Eo 'EXECUTABLE DIRECTORY: [^ ]+' | cut -d ' ' -f3)

# 检测你使用的shell并选择相应的配置文件
if [[ $SHELL == */zsh ]]; then
    # 对于zsh
    CONFIG_FILE="${HOME}/.zshrc"
elif [[ $SHELL == */bash ]]; then
    # 对于bash
    CONFIG_FILE="${HOME}/.bash_profile"
    if [ ! -f "$CONFIG_FILE" ]; then
        CONFIG_FILE="${HOME}/.bashrc"
    fi
else
    echo "Unsupported shell."
    exit 1
fi

# 检查GEM_BIN_DIR是否已经在PATH中
if [[ ":$PATH:" != *":$GEM_BIN_DIR:"* ]]; then
    # 如果不在PATH中，添加它
    echo "Exporting GEM bin directory to PATH in $CONFIG_FILE"
    echo "export PATH=\"\$PATH:$GEM_BIN_DIR\"" >> "$CONFIG_FILE"
    echo "Done. Please restart your terminal or source your $CONFIG_FILE"
else
    echo "GEM bin directory ($GEM_BIN_DIR) already in PATH."
fi
