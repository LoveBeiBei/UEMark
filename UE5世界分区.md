https://www.youtube.com/watch?v=ZxJ5DG8Ytog&t=1516s

https://www.youtube.com/watch?v=Y-CDWyQvKhA&t=508s

**古代山谷工作流与UE5新功能介绍**

https://www.youtube.com/watch?v=RJfqytepZ0c

## UE5开放世界新功能

World Partition：用于替代UE4中的World Composition，世界分区的方式替代子关卡流送机制

OFPA：场景中每个Actor单独保存为一个文件，解决多人合作时无法同时修改场景的问题 

Data Layer：用于Gameplay的场景资源管理，在Ancient Valley项目中，Data Layer也可以用于场景效果的切换

Level Instance：场景复用，一定程度上也可以解决多人合作时场景编辑的问题

HLOD：层级LOD

## 要点

1. UE5中默认使用World Partition替代World Composition管理场景资源，这种方式将场景资源按Actor位置所在Volume Cell进行分区而治的管理。因此该方式将不再支持子关卡进行关卡的流送。

   ![image-20220331141241042](https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220331141241042.png)

2. OFPA方案使场景中每个Actor使用单独的文件保存。当多人合作时，正在修改场景资源的开发人员可以将单独的Actor进行锁定，而不影响其他人修改场景。OFPA仅在Editor模式下使用，资源Cook后依然可以把Actor合并到Map文件。

   在文件目录中，每个Actor是匿名保存的，因此无法区分文件对应的Actor，但是UE5的SourceControl提供了文件修改列表，可以直观的看到实际的Actor名称。

   <img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220331153323274.png" alt="image-20220331153323274" style="zoom:67%;" />

## World Partition

### 世界分区窗口（Editor的网格管理）

1. 打开世界分区窗口。如果世界分区窗口没有正确显示分区网格，则需要在WorldSettings中首先启用Enable Streaming。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401143358018.png" alt="image-20220401143358018" style="zoom:67%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401143501939.png" alt="image-20220401143501939" style="zoom: 25%;" />

2. 在世界分区窗口中可以看到有许多Cell，通过选中Cell并右键可以看到菜单中有许多控制该Cell的选项，例如加载或卸载该网格。这些菜单项将会执行在关卡编辑器窗口中将属于该网格的Actors进行加载或卸载。如果一个Actor跨越两个Cell时，必须两个同时卸载才能将Actor卸载，只要有一个Cell执行加载，即可将Actor加载。
3. 在WorldSettings中可以通过以下设置修改世界分区窗口中Cell的大小，但该设置仅对Editor的Cell起作用，与Actor的流送距离无关。修改该参数后需要重新加载World才可生效。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401145917231.png" alt="image-20220401145917231" style="zoom: 80%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401150004309.png" alt="image-20220401150004309" style="zoom:33%;" />

### 流送（Runtime的网格流送管理）

Actor的流送以Cell为单位，如果Cell在玩家的可视范围内（流送源组件内）则进行Cell中Actor的流送。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401160056099.png" alt="image-20220401160056099" style="zoom: 50%;" />

在World Settings中可以设置Cell和流送源的尺寸：

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401163924798.png" alt="image-20220401163924798" style="zoom:67%;" />

Grid Cell Size是每个流送单位的尺寸，而Loading Range是流送源的半径。如下图是Cell Size和Loading Range相同时的流送范围：

![image-20220407112659583](https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220407112659583.png)

World Partition支持设置多层级的Grid Cell流送机制，可以在World Settings中添加新Grid层级，并设置不同的流送范围和Cell尺寸。比如默认的网格流送（MainGrid）设置为50米内加载，而一些Cell期望在距离更远时就加载。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401170708993.png" alt="image-20220401170708993" style="zoom:80%;" />

设置完多Grid Cell层级后，可以对Actor指定其所属Grid。然后Actor就可以按照该Grid的流送规则进行资源加载和卸载。如果没有设置Actor的Runtime Grid，则该Actor默认使用MainGrid规则。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401171004407.png" alt="image-20220401171004407" style="zoom:67%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401171026714.png" alt="image-20220401171026714" style="zoom:67%;" />

在Actor的WorldPartition中可以设置该Actor是通过流送加载还是Always Loaded。如果启用IsSpatiallyLoaded，则该Actor根据Grid Cell进行流送；如果没有启用，则Always Loaded。如果该Actor被添加到Data Layer中，则需要同时满足DataLayer的加载条件。

![image-20220401172720946](https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401172720946.png)

### 参考

https://docs.unrealengine.com/5.0/en-US/WorldFeatures/WorldPartition/

## Data Layers

### Editor下配置与管理Data Layers

可以将场景中Gameplay相关的Actor分配到不同数据层中，然后在Editor或Runtime下加载指定数据层的Actors。例如像破坏后的桥梁、建筑等也可以放到DataLayer中，通过逻辑控制显示破坏后的场景，并且这样也有助于美术开发能够快速比较前后效果。

这样的好处是美术人员在设计场景的时候可以把触发器、NPC等Gameplay相关的的Actors进行卸载，只关心场景资源。同时，在Runtime时可以根据功能需求加载不同组的Actors等。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401195316890.png" alt="image-20220401195316890" style="zoom:80%;" />

### Runtime下更新数据层状态

![image-20220401205013320](https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220401205013320.png)

## Level Instancing

### Level Instance

Level Instancing的主要功能是为非世界分区转换为世界分区地图服务的，因为世界分区不再支持子关卡流送，因此Level Instancing支持将子关卡转换为场景中的Level Instance Actor实例，并将子关卡中的Actor附加到该实例。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220402004026529.png" alt="image-20220402004026529" style="zoom:50%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220402004002426.png" alt="image-20220402004002426" style="zoom:50%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220402004149092.png" alt="image-20220402004149092" style="zoom:50%;" />

在World Partition中，可以右键选中的Actor，选择“Level/Create Level Instance... ”选项将选中的一组Actor转换为Level Instance，同时会在工作目录下创建该Level Instance实例对应的关卡。即将一组Actor转换为一个关卡。如果想要继续编辑该关卡，则需要右键选中该Level Instance并选择Level/Edit项或者直接在属性栏中操作。

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220402010332936.png" alt="image-20220402010332936" style="zoom:33%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220402005746691.png" alt="image-20220402005746691" style="zoom:33%;" />

<img src="https://private-notes.oss-cn-beijing.aliyuncs.com/assets/image-20220402005831838.png" alt="image-20220402005831838" style="zoom:33%;" />

### Packaged Level Actor

Packaged Level Actor可以将多个子关卡或者关卡实例保存到BP。

## HLOD

Instancing: 每个Cell是一个单独的Actor，每个资产为一个组件（不会损失视觉效果）

Merged and simplified: 每个Cell一个单独的Actor，但是模型和纹理会简化和合并

使用示例：

Loading range of 128M(fully streamed with physics, gamplay, ets).

Instanced from 128M to 768M(streamed, no visual quality loss-无视觉损失).

Merged from 768M to 2KM(streamed).

Merged from 2KM to infinity(always loaded).





