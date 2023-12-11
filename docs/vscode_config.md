# 配置 VSCode 
本篇文档描述如何在 vscode 配置 verilog：
- 下载 Verilog-HDL/SystemVerilog/Bluespec SystemVerilog 插件
- 下载 Ctags Companion 插件
- 根据 Ctags Companion 的提示下载 Ctags
- 执行 `ctags -R --fields=+nKz --langmap=Verilog:+.vh -R rtl` 去生成 Ctag 文件
- 在 Verilog-HDL/SystemVerilog/Bluespec SystemVerilog 插件中配置 linting 所用的工具，既可以在插件中设置，也可以在 `settings.json` 中设置：`"verilog.linting.linter": "verilator"`
- 在 `setting.json` 中配置 include path: 
```
"verilog.linting.verilator.includePath": [
        "${workspaceFolder}/rtl/",
    ]
```