# Pipelined ADC 仿真

## 文件分工

| 文件 | 内容 |
| --- | --- |
| `parameters.m` | ADC 参数、直流扫描点数及正弦测试参数 |
| `system_model.m` | 四种工况的级联配置及模型函数句柄 |
| `mdacStage.m` | 单级 MDAC 比较判决及残差模型 |
| `pipelineADC.m` | 各级比较和残差计算，合成 ADC 输出码 |
| `analyzeSpectrum.m` | FFT、PSD、SINAD、ENOB 分析 |
| `tb_Vres.m` | 单级残差测试，调用 `plot_Vres.m` |
| `tb_dc_transfer.m` | 直流扫描测试，调用 `plot_transfer.m` |
| `tb_ac_FFT.m` | 正弦加白噪声测试，调用频谱分析和绘图函数 |
| `plot_Vres.m` | 三种非理想工况与理想残差的对比图 |
| `plot_transfer.m` | 输入电压与输出码的传输曲线 |
| `plot_FFT.m` | 四种工况的频谱，标题显示 SINAD 和 ENOB |
| `plot_PSD.m` | 四种工况的功率谱密度 |
| `saveSimulationFigure.m` | 将图窗保存到 `simulation_results` |
| `simulation_results/` | 自动生成的 PNG 和 FIG 仿真图 |
| `docs/git_and_formatting.md` | Git 版本管理与 MATLAB formatter 教程 |
| `miss_hit.cfg` | MISS_HIT 的缩进、空格及行长配置 |
| `.editorconfig` | 支持 EditorConfig 的编辑器使用的基础格式规则 |
| `.gitattributes` | 固定代码与文档的 LF 换行，减少跨平台格式差异 |

公共参数和级联配置由各 testbench 加载。模型、频谱分析和绘图函数均以参数传递数据，每个函数单独放在一个同名 `.m` 文件中。

## 运行方式

在 MATLAB 中打开任意 `tb_*.m`，点击运行。也可以在项目根目录分别执行：

```matlab
run('tb_Vres.m');
run('tb_dc_transfer.m');
run('tb_ac_FFT.m');
```

每个入口都会清空工作区、命令窗口并关闭已有图窗，因此应按需单独运行。数值结果保留在工作区，绘图函数会自动将图片保存到项目根目录下的 `simulation_results`，与 MATLAB 当前工作目录无关。同名图在再次运行时覆盖。

| 入口 | 保存的仿真图 |
| --- | --- |
| `tb_Vres.m` | `Vres.png`、`Vres.fig` |
| `tb_dc_transfer.m` | `dc_transfer.png`、`dc_transfer.fig` |
| `tb_ac_FFT.m` | `ac_FFT.png`、`ac_FFT.fig`、`ac_PSD.png`、`ac_PSD.fig` |

PNG 可直接查看或插入文档，FIG 可在 MATLAB 中通过 `openfig` 重新打开和编辑。重新绘图时传入对应测试留下的数据，例如：

```matlab
plot_Vres(Vin, VresIdeal, VresMismatch, VresOffset, finiteResidue, VREF);
```

绘图使用 `tiledlayout` 和 `exportgraphics`，需要 MATLAB R2020a 或更新版本。Hann 窗通过公式生成，频谱分析使用基础 MATLAB 函数，无需 Signal Processing Toolbox。

## 模型与参数

默认分辨率为 8 bit、参考电压为 1 V，输入范围为 `[0,VREF]`。前 `Nbits-1` 级完成比较和残差放大，末级仅比较，输出各位按二进制权重合成数字码。

四种工况依次为：理想、电容失配、比较器失调、有限运放增益。非理想工况仅第一级引入对应误差，其余级保持理想。

在 `parameters.m` 中修改参数：

| 参数 | 默认值 | 含义 |
| --- | --- | --- |
| `VREF` | `1` | 参考电压，V |
| `Nbits` | `8` | ADC 分辨率 |
| `C1` | `1e-12` | 电容，F；模型实际使用电容比 |
| `mismatch` | `0.30` | 电容失配 `C2/C1-1` |
| `Vos` | `0.10*VREF` | 比较器输入失调，V |
| `A0` | `20` | 运放直流开环增益，V/V |
| `nPoints` | `4001` | 残差和直流传输测试的扫描点数 |
| `Fs` | `1e6` | 交流测试采样率，Hz |
| `Nfft` | `2^14` | 交流测试采样点数，也是 FFT 点数 |
| `nCycles` | `127` | 采样记录内的正弦周期数 |
| `Fin` | `nCycles*Fs/Nfft` | 输入频率，Hz |
| `Ain` | `0.499*VREF` | 正弦峰值幅度，V |
| `Vcm` | `VREF/2` | 输入直流偏置，V |

模型通过 `model.mdacStage`、`model.pipelineADC` 两个函数句柄调用。必须先执行 `parameters`，再执行 `system_model`。

## 白噪声与加窗

在 `tb_ac_FFT.m` 开头设置：

```matlab
noisePower = 1e-8;
useHann = true;
rng(1);
```

`noisePower` 是输入白噪声的目标方差，单位 V²，设为 `0` 关闭噪声；`useHann` 为 `true` 使用周期 Hann 窗，为 `false` 使用矩形窗；`rng(1)` 固定随机种子，便于比较。

输入噪声由 `sqrt(noisePower) * randn(Nfft, 1)` 生成，是零均值高斯白噪声。`noisePower` 不是 dB 或每 Hz 的功率密度；有限记录的实际均方值会略有波动。默认噪声 RMS 为 `1e-4 V`，四种工况使用同一份带噪输入。

当前分析仍按相干采样设计：保持 `Fin=nCycles*Fs/Nfft`，使用偶数 `Nfft` 和整数 `nCycles`，建议二者互质。基波还需远离直流和 Nyquist 频点，满足 `1<nCycles<Nfft/2-1`。开启 Hann 窗不代表支持任意非相干输入频率。

关闭加窗时，基波功率取中心频点；开启 Hann 时，合计中心及相邻两个频点。两种模式均按窗能量归一化，SINAD 分母统计除直流与基波频点外的功率，包含谐波。基波频点内的噪声未另行估计。

## 结果读取

直流测试保留各工况的 `code*`、`bits*`、`residues*`，分别表示输出码、各级判决和各级输入残差；`residues*` 第一列为原始输入。

交流测试的 `codes` 每列对应一种工况，顺序为理想、电容失配、比较器失调、有限增益。分析结果存入 `result`：

| 字段 | 含义 |
| --- | --- |
| `f` | 单边频率轴，Hz |
| `FFT_dBFS` | 每个频点的功率，以满量程正弦功率 `VREF^2/8` 为参考 |
| `PSD` | 线性功率谱密度，V²/Hz；图中转换为相对 1 V²/Hz 的 dB 值 |
| `SINAD` | 基波功率与噪声加失真功率之比，dB |
| `ENOB` | `(SINAD-1.76)/6.02`，适用于接近满量程正弦测试 |

Hann 窗会将基波功率分布到相邻频点，因此单个频点的峰值不能直接当作整个基波功率。PSD 乘频率间隔 `Fs/Nfft` 后求和，得到窗加权的去直流信号均方值。

## 模型范围

模型不包含采样开关、运放建立时间、时钟抖动或流水线时延；`Fs` 用于生成激励和频率轴，不会自动引入动态电路误差。内部残差不裁剪，输入白噪声也不额外限幅。增大噪声功率时应关注输入是否超出 `[0,VREF]`。

源自 Behzad Razavi 的 *A Tale of Two ADCs: Pipelined Versus SAR*，IEEE Solid-State Circuits Magazine，Summer 2015，pp. 38–46，DOI：10.1109/MSSC.2015.2442372。

## 代码格式与版本管理

代码使用 4 个空格缩进，循环索引用 `stageIndex`、`caseIndex`、`panelIndex` 等名称。优先让代码和命名表达意图，确有必要的注释使用英文；尽量将完整表达式写在一行，不为固定的窄行宽频繁使用 `...`。

文件名保持稳定，用 Git 提交和标签记录版本。仿真图和 MATLAB 自动备份文件由 `.gitignore` 忽略，仅保留结果目录的 `.gitkeep`。具体操作见 [Git 与 MATLAB 格式化教程](docs/git_and_formatting.md)。
