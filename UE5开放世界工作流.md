# 地形系统

## 地形创建

开放世界的地图尺寸非常大，显然不可能直接使用3DMAX等建模软件制作的静态模型文件，一般来说引擎都会有一套地形系统（Landscape）来支持地形的生成和渲染。**引擎的地形系统根据高度图来构造地形**，对于相同的顶点密度，模型数据形式的地形占用的内存是高度图的6-7倍。而且地形系统还提供强大的LOD功能，远处的地形网格顶点会被优化减少，分块渲染等等功能。

**World Creator->Houdini->UE5**

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408111310368.png" alt="image-20220408111310368" style="zoom:50%;" />

## 地形编辑

### 拆分地形块

UE5中支持创建多个地形块，如果每个地形块的尺寸是2km x 2km，要创建一个10km x 10km的地图，则需要5 x 5个地形块。

地形分块的优点：

1. 分块管理地形
2. 每个地形块的Component为32 x 32，如果地形比较大，每个地形Component也将会比较大。通过拆分地形块，可以减小每个Component的大小，使地形分辨率更高更精致

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220406105655042.png" alt="image-20220406105655042" style="zoom: 67%;" />

在Unreal引擎地形参数中，主要包含了三个参数：

Component
Section
Quad

这三个参数从上至下是包含关系，即：一块地形中可包含多个Component，一个Component可以包含多个Section，一个Section可以包含多个Quad。而Quad则是地形网格中最小的四边形。接下来我们分别介绍这三个参数的设置。

1.1 Component
在Unreal引擎的地形中，Component实际上是裁剪、渲染以及碰撞检测的基本单元。Unreal引擎在渲染地形时，一个Component要么被整体裁剪掉，要么被整体渲染出来并参与碰撞检测的计算。而其数量则是通过New Landscape窗口中的Number of Components参数进行设置，如下图所示：

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220406122943476.png" alt="image-20220406122943476" style="zoom:50%;" />

1.2 Section
在Unreal引擎的地形中，Section实际上是LOD的基本单元。其中，一个Component中可以包含1（1x1）个或者4（2x2）个Section。它的数量可以通过Sections Per Component进行设置，如下图所示：

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220406123039558.png" alt="image-20220406123039558" style="zoom:50%;" />

1.3 Quad
在Unreal引擎的地形中，Quad决定了最后生成的地形网格的顶点数。其数量可通过Section Size参数进行设置，如下图所示：

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220406123142059.png" alt="image-20220406123142059" style="zoom:50%;" />



### 地形层级

将World Creator中创建的HeightMap导入到游戏编辑器中后，可以通过UE5编辑器的Landscape模块对地形进行二次编辑。UE5支持地形层级，一般我们将World Creator生成的地形保存到Base Layer层，而每次在游戏编辑器中修改的地形结果放到Macro层，当不满意修改结果时，可以轻松的抹掉还原成原始的HeightMap。

在《幽灵行动：荒野》中建立了一个DCC的地形层，该层由Houdini控制。最后还有个Micro层，包含了不能使用Houdini设计的相关修改，通常是微观景色。

![image-20220406112938869](https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220406112938869.png)

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408111536907.png" alt="image-20220408111536907" style="zoom: 50%;" /><img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408111703258.png" alt="image-20220408111703258" style="zoom:50%;" />

### 地形修改

如果希望修改地形图，UE5支持原地形和编辑后的地形Heigtmap导出和导入。导出时，每四个Component合并成一块。导入时，可以支持仅导入修改的地形块部分。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408110756228.png" alt="image-20220408110756228" style="zoom: 67%;" />            <img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408110831623.png" alt="image-20220408110831623" style="zoom:67%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408111023742.png" alt="image-20220408111023742" style="zoom: 50%;" />



![image-20220408111125928](https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408111125928.png)          ![image-20220408111148031](https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220408111148031.png)



# World Partition

[文档引用]: 世界分区.md



# 其它问题

**DS网络同步**

服务器因为需要保存当前整个游戏的场景状态和寻路导航等原因，所以DS服务器会加载整张大地图。例如：当玩家破坏了场景，客户端不需要记录状态可以任意的流送场景，但服务器需要保持场景状态用于同步恢复客户端的场景状态，因为服务器一旦卸载了部分场景，再加载时，将会恢复原状，因此服务器需要加载并保持整张地图的状态直至当前游戏结束。因此，硬件消耗较大，至少在UE5 Preview阶段存在该问题，Epic官方也在尝试解决该问题，使其在服务器仅流送部分分区并可以恢复状态。

如果仅将DS服务器用于类似原神中神庙等这种小关卡效果会好些。开放世界场景可以刷小怪，副本小场景可以刷boss。

总结就是DS服务器的游戏效果会更好，但硬件消耗也很大。如果可以解决服务器仅加载开放世界中部分场景的问题，DS服务器副本Boss也可以出现在开放世界中。

**射击开镜**

远距离场景因为没有流送或者使用了HLOD，还有同步等原因，通常无法远距离角色交互。像大场景的射击游戏因此受限，一个解决思路是限制射击范围，例如1KM，并将流送源范围也设置为1KM等。这种问题需要根据游戏类型，例如吃鸡，作出针对性的解决方案。

**Source Control: SVN**

UE5的版本管理对SVN似乎不完善或有BUG，ChangeList无法使用（当前仅支持Perforce），不Check Out的文件，提交时无法检查出来，也不能全部check out。

官方会优先开发Perforce的功能。

****

#### Gameplay辅助功能

**Game Features**

**Enhance Input**

**DataRegistry**



