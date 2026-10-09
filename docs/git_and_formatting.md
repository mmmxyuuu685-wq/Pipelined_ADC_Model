# Git 版本管理与 MATLAB 代码格式

以后直接使用 `pipelineADC.m`、`mdacStage.m` 等稳定文件名。Git 会记录每次提交的内容和说明；需要标记一个阶段时使用标签，不必创建“第 2 版”“最终版”等文件副本。

## 1. 先理解三个位置

| 位置 | 含义 | 查看命令 |
| --- | --- | --- |
| 工作区 | 磁盘上正在编辑的文件 | `git diff` 查看尚未暂存的改动 |
| 暂存区 | 下一次提交准备包含的改动 | `git diff --cached` |
| 提交历史 | 已保存的版本记录 | `git log --oneline` |

`git add` 把指定文件当前的改动放进暂存区，`git commit` 保存暂存区的**全部**内容。暂存后继续编辑同一文件，新改动不会自动进入暂存区，需要再次 `git add`。[Git 官方教程](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository)

在 PowerShell 中进入项目目录：

```powershell
Set-Location 'C:\Users\Dexter\Desktop\Pipelined_ADC_Model'
git status --short
git diff
git diff --cached
```

当前分支是 `main`，仓库已有 `origin` 远程地址。现有暂存区还可能包含之前的重命名和删除记录，所以每次提交前都要检查 `git diff --cached`；只添加几个文件不会自动移除以前暂存的内容。

## 2. 一次完整的修改流程

例如，调整 ADC 模型后运行相关仿真，并检查生成的曲线。`tb_Vres.m`、`tb_dc_transfer.m`、`tb_ac_FFT.m` 会把 PNG 和 FIG 保存到项目的 `simulation_results` 文件夹。该目录的仿真输出已被 `.gitignore` 排除，目录占位文件 `.gitkeep` 保留在仓库中。

确认修改正确后，只暂存本次需要提交的文件：

```powershell
git diff -- pipelineADC.m mdacStage.m system_model.m
git add -- pipelineADC.m mdacStage.m system_model.m
git status --short
git diff --cached
git commit -m "Refactor ADC model into separate function files"
git log --oneline -5
```

上面的文件名和提交说明是示例，请按实际修改替换。提交说明写清楚“做了什么”，一次提交尽量解决一个明确问题。`git status --short` 第一列表示暂存区状态，第二列表示工作区状态；`??` 表示尚未跟踪的新文件。

如果 `git diff --cached` 中出现不属于本次提交的文件，先取消这些文件的暂存，再检查一遍。不要直接使用 `git add .` 来代替审查。

## 3. 用分支尝试新方案，用标签标记版本

先完成或妥善处理当前改动，再从 `main` 建一个实验分支：

```powershell
git switch main
git switch -c feature/adc-gain-study
```

在新分支上修改、仿真并提交。验证完成后合并到 `main`：

```powershell
git switch main
git merge feature/adc-gain-study
```

如果合并提示冲突，需要检查冲突文件、保留正确代码、重新仿真，再暂存并提交；不要盲目覆盖另一边的内容。[Git 分支切换文档](https://git-scm.com/docs/git-switch)

某次提交验证通过后，可以加一个有说明的标签：

```powershell
git tag -a v1.0 -m "Validated ADC model baseline"
git tag
git show v1.0
git diff v1.0 HEAD -- pipelineADC.m
```

`v1.0` 指向当时的提交，后续继续修改原来的文件即可。标签名要唯一；示例名字已存在时换一个新名字。[Git 标签教程](https://git-scm.com/book/en/v2/Git-Basics-Tagging)

## 4. 撤销时分清“取消暂存”和“丢弃修改”

取消某个文件的暂存，保留工作区内容：

```powershell
git restore --staged -- pipelineADC.m
```

下面这条命令会丢弃该文件工作区中尚未暂存的修改，并用暂存区版本覆盖它。**只有确认不再需要这些改动时才执行；Git 通常无法恢复从未提交过的内容。**

```powershell
git restore -- pipelineADC.m
```

查看旧提交中的文件不会修改当前文件：

```powershell
git log --oneline -- pipelineADC.m
git show v1.0:pipelineADC.m
```

撤销已经提交、尤其是已分享给别人的提交，优先用 `git revert` 创建一条反向提交，保留历史记录。[Git restore 文档](https://git-scm.com/docs/git-restore)

需要把提交上传到已有远程仓库时，先检查目标，再按实际分支执行：

```powershell
git remote -v
git push -u origin feature/adc-gain-study
git push origin main
git push origin v1.0
```

这些上传命令不是日常保存所必需的，也无需一起执行；本地 `git commit` 已经保存版本。

## 5. MATLAB 缩进与 formatter

本项目采用 4 个空格缩进，每个函数放在同名 `.m` 文件中。代码通过清楚的命名表达意图，注释尽量少，必要注释使用英文。循环索引使用 `stageIndex`、`sampleIndex` 等有含义的名字；避免 `i`、`j`，复数常量可明确写成 `1i`。长表达式有阅读需要时再使用 `...`，不要为了固定窄行宽频繁拆行。

在 MATLAB R2024b 中，打开 **Home → Preferences → MATLAB → Editor/Debugger**，将 **Tab size** 和 **Indent size** 都设为 `4`，勾选 **Tab key inserts spaces**。在 **Language** 页选择 MATLAB，启用 **Apply smart indenting while typing**，将 **Function indenting format** 设为 **Indent all functions**。打开文件后按 `Ctrl+A` 全选，再按 `Ctrl+I` 执行 Smart Indent。它主要整理缩进，不会完整统一运算符空格等样式。[MathWorks 编辑与格式说明](https://www.mathworks.com/help/matlab/matlab_prog/edit-and-format-code.html)、[Smart Indent 示例](https://blogs.mathworks.com/community/2009/05/11/keep-your-code-readable-with-smart-indenting/)

项目已提供三份配置：`miss_hit.cfg` 配置 MATLAB formatter；`.editorconfig` 为支持它的编辑器指定空格、缩进和换行；`.gitattributes` 统一 Git 管理的文本换行。`.editorconfig` 是否生效取决于编辑器支持，不能代替 formatter。

可以安装开源工具 MISS_HIT，在项目根目录运行。下面使用当前电脑的 Python 路径；安装需要能连接 Python 包源，配置文件本身不会自动安装工具。

```powershell
& 'D:\mini\python.exe' -m pip install miss_hit
& 'D:\mini\python.exe' -m miss_hit.mh_style --brief .
& 'D:\mini\python.exe' -m miss_hit.mh_style --fix --brief .
git diff
git diff --cached
```

第一条样式命令只检查，带 `--fix` 的命令会直接修改文件；仅对已提交或已备份的代码执行自动修复，修复后检查差异并运行受影响的仿真。部分问题仍需手动处理。[MISS_HIT 官方仓库](https://github.com/florianschanda/miss_hit)、[样式检查器文档](https://florianschanda.github.io/miss_hit/style_checker.html)

本次下载 MISS_HIT 时，当前镜像和官方 PyPI 均出现 SSL 连接错误，因此工具尚未安装，命令未实跑。代码格式已手动整理并检查；解决包源连接问题后即可使用这些命令。

`miss_hit.cfg` 使用 4 个空格、函数体缩进和 LF 换行，行长检查设为 240 字符，排除 `simulation_results`。行长是检查阈值，不是要求每行写满，也不是自动插入 `...` 的指令。配置还关闭版权声明和部分命名检查，减少与项目约定无关的提示。[MISS_HIT 配置文档](https://florianschanda.github.io/miss_hit/configuration.html)

建议先单独提交格式调整，再提交算法修改。这样查看历史和排查结果变化时，能更容易找到真正影响模型行为的改动。
