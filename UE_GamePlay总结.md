首发于[InsideUE5](https://www.zhihu.com/column/insideue4)

# 《InsideUE4》GamePlay架构（十）总结

> 世界那么大，我想去看看

## 引言

通过对前九篇的介绍，至此我们已经了解了UE里的游戏世界组织方式和游戏业务逻辑的控制。行百里者半九十，前述的篇章里我们的目光往往专注在于特定一个类或者对象，一方面固然可以让内容更有针对性，但另一方面也有了身在山中不见山的困惑。本文作为GamePlay章节的最终章，就是要回顾我们之前探讨过的内容，以一个更高层总览的眼光，把之前的所有内容有机组织起来，思考整体的结构和数据及逻辑的流向。

## 游戏世界

如果我们在最初篇所问的，如果让你来制作一款3D游戏引擎，你会怎么设计其结构？已经知道，在UE的眼里，游戏世界的万物皆Actor，Actor再通过Component组装功能。Actor又通过UChildActorComponent实现Actor之间的父子嵌套。([GamePlay架构（一）Actor和Component](https://zhuanlan.zhihu.com/p/22833151))

![](https://pic1.zhimg.com/80/v2-91234c7d5bc32dd04c7221ac9dcc56d0_720w.jpg)

众多的各种Actor子类又组装成了Level([GamePlay架构（二）Level和World](https://zhuanlan.zhihu.com/p/22924838)):![](https://pic3.zhimg.com/80/v2-14a202ba552576c2505073cb1543eeae_720w.png)

如此每一个Level就拥有了一座Actor的森林，你可以根据自己的需要定制化Level，比如有些Level是临时Loading场景，有些只是保存光照，有些只是一块静态场景。UE用Level这种细一些粒度的对象为你的想象力提供了极大的自由度，同时也能方便团队内的平行协作。

一个个的Level，又进一步组装成了World:

![](https://pic2.zhimg.com/80/v2-4b0a3d9cb6479a1c8efe736046c06dc5_720w.png)

就像地球上的大陆板块一样，World允许多个Level静态的通过位置摆放在游戏世界中，也允许运行时动态的加载关卡。

而World之间的切换，UE用了一个WorldContext来保存切换的过程信息。玩家在切换PersistentLevel的时候，实际上就相当于切换了一个World。而再往上，就是整个游戏唯一的GameInstance，由Engine对象管理着。([GamePlay架构（三）WorldContext，GameInstance，Engine](https://zhuanlan.zhihu.com/p/23167068))

![](https://pic2.zhimg.com/80/v2-19ce8ccbd2e444a8fb27459614aa602d_720w.png)

到了World这一层，整个游戏的渲染对象就齐全了。但是游戏引擎并不只是渲染，因此为了让玩家也各种方式接入World中开始游戏。GameInstance下不光保存着World，同时也存储着Player，有着LocalPlayer用于表示本地的玩家，也有NetConnection当作远端的连接。（[GamePlay架构（八）Player](https://zhuanlan.zhihu.com/p/23826859)）：

![](https://pic2.zhimg.com/80/v2-e7fc2230978792cb4ea8552337a11565_720w.png)

玩家利用Player对象接入World之后，就可以开始控制Pawn和PlayerController的生成，有了附身的对象和摄像的眼睛。最后在Engine的Tick心跳脉搏驱动下开始一帧帧的逻辑更新和渲染。

## 数据和逻辑

说完了游戏世界的表现组成，那么对于一个GamePlay框架而言自然需要与其配套的业务逻辑架构。GamePlay架构的后半部分就自底向上的逐一分析了各个层次的逻辑载体，按照MVC的思想，我们可以把整个游戏的GamePlay分为三大部分：表现（View）、逻辑（Controller）、数据（Model）。一图胜千言：

![](https://pic3.zhimg.com/80/v2-b4e0dd15956ccb819fca93e73d1b8ed2_720w.jpg)

(请点击看大图)
最左侧的是我们已经讨论过的游戏世界表现部分，从最最根源的UObject和Actor，一直到UGameEngine，不断的组合起来，形成丰富的游戏世界的各种对象。

1. 从UObject派生下来的AActor，拥有了UObject的反射序列化网络同步等功能，同时又通过各种Component来组装不同组件。UE在AActor身上同时利用了继承和组合的各自优点，同时也规避了彼此的一些缺点，我不得不说，UE在这一方面度把握得非常的平衡优雅，既不像cocos2dx那样继承爆炸，也不像Unity那样走极端全部组件组合。
2. AActor中一些需要逻辑控制的成员分化出了APawn。Pawn就像是棋盘上的棋子，或者是战场中的兵卒。有3个基本的功能：可被Controller控制、PhysicsCollision表示和MovementInput的基本响应接口。代表了基本的逻辑控制物理表示和行走功能。根据这3个功能的定制化不同，可以派生出不同功能的的DefaultPawn、SpectatorPawn和Character。([GamePlay架构（四）Pawn](https://zhuanlan.zhihu.com/p/23321666))
3. AController是用来控制APawn的一个特殊的AActor。同属于AActor的设计，可以让Controller享受到AActor的基本福利，而和APawn分离又可以通过组合来提供更大的灵活性，把表示和逻辑分开，独立变化。([GamePlay架构（五）Controller](https://zhuanlan.zhihu.com/p/23480071))。而AController又根据用法和适用对象的不同，分化出了APlayerController来充当本地玩家的控制器，而AAIController就充当了NPC们的AI智能。([GamePlay架构（六）PlayerController和AIController](https://zhuanlan.zhihu.com/p/23649987))。而数据配套的就是APlayerState，可以充当AController的可网络复制的状态。
4. 到了Level这一层，UE为我们提供了ALevelScriptActor（关卡蓝图）当作关卡静态性的逻辑载体。而对于一场游戏或世界的规则，UE提供的AGameMode就只是一个虚拟的逻辑载体，可以通过PersistentLevel上的AWorldSettings上的配置创建出我们具体的AGameMode子类。AGameMode同时也是负责在具体的Level中创建出其他的Pawn和PlayerController的负责人，在Level的切换的时候AGameMode也负责协调Actor的迁移。配套的数据对象是AGameState。([GamePlay架构（七）GameMode和GameState](https://zhuanlan.zhihu.com/p/23707588))
5. World构建好了，该派玩家进来了。但游戏的方式多样，玩家的接入方式也多样。UE为了支持各种不同的玩家模式，抽象出了UPlayer实体来实际上控制游戏中的玩家PlayerController的生成数量和方式。([GamePlay架构（八）Player](https://zhuanlan.zhihu.com/p/23826859))
6. 所有的表示和逻辑汇集到一起，形成了全局唯一的UGameInstance对象，代表着整个游戏的开始和结束。同时为了方便开发者进行玩家存档，提供了USaveGame进行全局的数据配套。([GamePlay架构（九）GameInstance](https://zhuanlan.zhihu.com/p/24005952))

UE为我们提供了这些GamePlay的对象，说多其实也不多，而且其实也是这么优雅有机的结合在一起。但是仍然会把一些朋友给迷惑住了，常常就会问哪些逻辑该写在哪里，哪些数据该放在哪里，这么多个对象，好像哪个都可以。比如Pawn，有些人就会说我就是直接在Pawn里写逻辑和数据，游戏也运行的好好的，也没什么不对。

如果你是一个已经对设计架构了然于心，也预见到了游戏未来发展变化，那么这么直接干也确实比较快速方便。但是这么做其实隐含了两个前提，一是这个Pawn的逻辑足够简单，把MVC的三者混合在一起依然不超过你的心智负担；二是已经断绝了逻辑和数据的分离，如果以后本地想复用一些逻辑创建另一个Pawn就会很麻烦，而且未来联机多玩家的状态复制也不支持。但说回来，人类的一个最常见的问题就是自大，对自己能力的过度自信，对未来变化的虚假掌控感。程序员在自己的编程世界里，呼风唤雨操作内存设备惯了，这种强大的掌控感非常容易地就外延到其他方面去了。你现在写的代码，过几个月后再回头看，是不是经常觉得非常糟糕？那奇怪了，当初写的时候怎么就感觉信心满满呢？所以踩坑多了的人就会自然的保守一些。另一方面，作为团队里的技术高手或老人，我个人觉得也有支持同行和提携后辈的责任，对自己而言只是多花一点点力气，却为别人树立一个清晰的程序结构典范，也传播了设计思想。程序员何苦为难程序员。

但还有一些人喜欢那么硬怼着干的原因要嘛是对未来的可预见性不足（经验不足），要嘛是对程序设计的基本原则不够了解（程序能力不够），比如最简单的“单一职责”。在新手期，面对着UE的程序世界，虽然在已经懂的人眼里就那么几个对象，但是在新手眼里，往往就感觉复杂无比，面对未知，我们本能的反应是逃避，往往就倾向于哪些看起来这么用能工作，就像玩游戏一样，形成了你的“专属套路”。跟穷人忙于工作而没力气提高自己是一个道理。相信我，所有的高手都是从小白过来的，我敢保证，他出生的时候脑袋也肯定是一片空白！区别是有些人后来不怕麻烦的勤能补拙，他努力的去理解这种设计模式的优劣，不局限于自己已经掌握的一片舒适区内，努力去设想未来的各种变化和应对之法，最终形成自己的独立思考。高手只是比新手懂得更多想得更多一些而已。

闲话说完。在分析UE这么一个GamePlay系统的时候，就像UML有各种图一样，我们也应该从各个切面去分析它的构成。这里有两大基本原则：单一职责和变化隔离，但也可以说只有一个。所有的程序设计模式都只是在抽象变化，把变化都抽离开了，剩下的不就是单一职责了嘛。所以UE里对MVC的实践其实也只是在不断抽离出各个对象的变化部分，把Pawn的逻辑抽出来是Controller，把数据抽出来是PlayerState。把World的Level静态逻辑抽出来是关卡蓝图，把动态的游戏玩法抽离出来是GameMode，把游戏数据抽离出来是GameState。具体的每个层次的数据和逻辑的关系前文已经一一详细说过了，此处就不再赘述了。但也再次着重探讨一些分析方法：

* 从竖直的角度来看，左侧是表示，中间是逻辑，右侧是数据。
  * 当我们谈到表示的时候，脑袋里想的应该是一个单纯的展示对象，就像一个基本的网络物体，它可以带一些基本的动画，再多一些功能，也顶多只能像一个木偶，有着一些非常机械原始的行为。我们让他前进，他可以知道左腿右腿交替着迈，但他是无知觉的。所以左侧的那一串对象，你应该尽量得让他们保持简单。
  * 实现中间的逻辑的时候，你应该专注于逻辑本身，尽量的忘记两旁的表示和数据。去思考哪些逻辑是表示固有的还是比较智能判断的。哪些Controller或Mode我们应该尽量的让它们通用，哪些就让它们特定的负责某一块，有些也不能强求，自己把握好度。
  * 右侧的数据，同样的保持简单。我们把它们分离出来的目的就是为了独立变化和在网络间同步，注意一下别走回头路了就好。我们应该只在此放置纯数据。
* 从水平的切面上看，依次自底向上，记住一个原则，哪个层次的应该尽量只负责哪个层次的东西，不要对上层或下层的细节知道得太多，也尽量不要逾矩越权去指手画脚别的对象里的内务事。大家通力协作，注重隐私，保持安全距离，不就社会和谐了嘛。
  * 最底层的Component，应该只是实现一些与游戏逻辑无关的功能。理解这个“无关”是关键。换个游戏，你这些Component依然可以用，就是所谓的游戏无关。
  * Actor层，通过Pawn、Controller和PlayerState的合作，根据需要旗下再派生出特定的Character，或PlayerController，AIController，但它们的合作模式，三大家族的长老们已经定下了，后辈们应该尽量遵守。这一层，关键的地方在于分清楚哪些是操作Actor的，别向下把Actor内部的功能给抽了出来，也别大包大揽把整个游戏的玩法也管了过来。脑袋保持清醒，这一层所做的事，就是为了让Actor们显得更加的智能。换句话说，这些智能的Actor组合，理论上是可以在随便哪个Level里用的。
  * Level和World层，分清楚静态的关卡蓝图和动态可组合GameMode。静态的意思是这个场景本身的运作机制，动态的指的是可以像切换比赛方式一样切换一场游戏的目的。在这一层上，你得有总览游戏大局的自觉了，咱们都是干大事的人，眼光就不要局限在那些一兵一卒那些小事了。制定好游戏规则，赋予这一场游戏以意义，是GameMode最重要的职责。注意两点，一是脑袋里有跟弦，一旦开始联机环境了，GameMode就升职到Server里去了，Client就没有了，所以千万要小心别在GameMode做些客户端的小事；二是GameState是表示一场游戏的数据的，而PlayerState是表示Controller的数据，对象和范围都不同，不能混了。
  * GameInstance层，一般来说Player不需要你做太多事情，UE已经帮你处理好了。虽说力量越大，责任就越大，但领导日理万机累坏了也不行是吧。所以GameInstance作为全局的唯一逻辑对象，我们如果能不打扰他就尽量少把事推给他，否则你很快就会看着GameInstance里堆着一山东西。GameInstance身在高层，应该只尽量做一些Level之间的协调工作。而SaveGame也应该尽量只保存游戏持久的数据。

自始至终，回顾一下每个类的本身的职责，该是他的就是他的，别人的不要抢。读者朋友们，如果到此觉得似乎懂了一些，但还是觉得不够深刻理解的话，也没关系，凡事不能一蹴而就，在开发过程中多想多琢磨自然而然就会慢慢领悟了。

## 整体类图

从类的继承层次上，咱们再加深一下理解。下图只列出了GamePlay架构里一些相关的重要的类：

![]()

(请点击看大图)
由此也可以看出来，UE基于UObject的机制出发，构建出了纷繁复杂的游戏世界，几乎所有的重要的类都直接或间接的继承于UObject，都能充分利用到UObject的反射等功能，大大加强了整体框架的灵活度和表达能力。比如GamePlay中最常用到根据某个Class配置在运行时创建出特定的对象的行为就是利用了反射功能；而网络里的属性同步也是利用了UObject的网络同步RPC调用；一个Level想保存成uasset文件，或者USaveGame想存档，也都是利用了UObject的序列化；而利用了UObject的CDO（Class Default Object），在保存时候也大大节省了内存；这么多Actor对象能在编辑器里方便的编辑，也得益于UObject的属性编辑器集成；对象互相引用的从属关系有了UObject的垃圾回收之后我们就不用担心会释放问题了。想象一下如果一开始没有设计出UObject，那么这个GamePlay框架肯定是另一番模样了。

## 总结

对于GamePlay我们从构建游戏世界开始，再到一层层的逻辑控制，本篇也从各个切面上总结归纳了整体架构。希望读者们好好领会UE的GamePlay架构思想，别贪快，整体上慢慢琢磨以上的架构图，细节上可以回顾过往的单篇来了解。

对于这一套UE提供的GamePlay框架，我们既然选择了用UE引擎，那么自然就应该想着怎么充分利用好它。框架就是你如果在它的规则下办事，那它就是事半功倍的助力器，你会常常发现UE怎么连这个也帮你做完了；而如果你在不了解的情况下想逆着它行事，就常常感受到怎么哪里都受到束缚。我们对于框架的理念应该就像是对待一辆汽车一般，我们关心的是怎么驾驶它到达想要的目的他，而不是折腾着怪它四个轮子不能按照你的心意朝不同方向乱转。对比隔壁的Cocos2dx、或Unity、或CryEngine，UE能够提供这么一个完善的GamePlay框架，对我们开发者而言，是一件幸福的事，不是吗？

## 结束语

完结撒花！GamePlay大章节也终于结束了，最开始是本着怎么尽早尽大的能帮助到读者朋友们，所以选择了GamePlay作为起始章节。相信GamePlay也是开发者们日常开发过程中接触最多，也是有可能混淆最多，概念不清，很容易用错的一块主题。在介绍GamePlay的时候，更多的重点是在于介绍各对象的职责和关联，所以更多是用类图来描述结构，反而对源码进行剖析的机会不多，但读者们可以自己去阅读验证。希望GamePlay架构的一系列十篇文章能切实地帮助到你们。

而下个专题，根据QQ群友们的投票反馈，决定了是UObject！有相当部分开发人员，可能不知道也不太关心UObject的内部机制。清楚了UObject，确实对于开发游戏并没有多少直接的提升，但《InsideUE4》系列教程的初衷就是为了深入到引擎内部提高开发者人员的内功。对于有志于想掌握好UE的开发者而言，分析一个游戏引擎，如果只是一直停留在高层的交互，而对于最底层的对象系统不了解的话，那就像云端行走一般，自身感觉飘飘然，但是总免不了内心里有些不安，学习和使用的脚步也会显得虚浮。因此在下个专题，我们将插入UObject的最最深处，把UObject扒得一毛不挂，慢慢领会她的美妙！我们终于有机会得偿心愿，细细把玩一句句源码，了解关于UObject的RTTI、反射、GC、序列化等等的内容。如果你也曾经好奇NewObject里发生了些什么、困惑CreateDefaultSubObject为何只能在构造函数里调用、不解GC是如何把对象给释放掉了、uasset文件里是些什么……

敬请期待下个专题：UObject！

*UE4.14*

---

知乎专栏：[InsideUE4](https://zhuanlan.zhihu.com/insideue4)

UE4深入学习QQ群： **456247757** (非新手入门群，请先学习完官方文档和视频教程)

微信公众号： **aboutue** ，关于UE的一切新闻资讯、技巧问答、文章发布，欢迎关注。

**个人原创，未经授权，谢绝转载！**

编辑于 2016-12-22 13:59

「如果您觉得本篇物有所值，可以请我喝杯咖啡」

赞赏

20 人已赞赏

[![赞赏用户](https://pic2.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_l.jpg?source=d16d100b)](https://www.zhihu.com/people/zi-qiang-bu-xi-76-79)[![赞赏用户](https://pica.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_l.jpg?source=d16d100b)](https://www.zhihu.com/people/yhpku)[![赞赏用户](https://pic2.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_l.jpg?source=d16d100b)](https://www.zhihu.com/people/hai-kuo-tian-kong-15-55-21)[![赞赏用户](https://pic2.zhimg.com/v2-111cb439fd9de3448b24d8eab0bfc300_l.jpg?source=d16d100b)](https://www.zhihu.com/people/gjp1111)[![赞赏用户](https://pic1.zhimg.com/v2-fa27f08792602ed4b6d4e4738a974e15_l.jpg?source=d16d100b)](https://www.zhihu.com/people/shui-jue-qian-chi-yao)

[游戏引擎](https://www.zhihu.com/topic/19556258)

[虚幻引擎](https://www.zhihu.com/topic/19824201)

[游戏开发](https://www.zhihu.com/topic/19553361)

赞同 39248 条评论

分享

喜欢收藏申请转载

赞同 392


分享

### 文章被以下专栏收录

[![InsideUE5](https://pic1.zhimg.com/v2-c11ce6a243a272cdab4264de925654cd_xs.jpg?source=172ae18b)](https://www.zhihu.com/column/insideue4)

## [InsideUE5](https://www.zhihu.com/column/insideue4)

深入UE5剖析源码，浅出游戏引擎架构理念

### 推荐阅读

[![《InsideUE4》GamePlay架构（十一）Subsystems](https://pic3.zhimg.com/v2-7825335e062ee2125ea8c28efed80c9d_250x0.jpg?source=172ae18b)《InsideUE4》GamePlay架构（十一）Subsystems大钊**发表于Insid...**](https://zhuanlan.zhihu.com/p/158717151)[![《InsideUE5》GameFeatures架构（五）AddComponents](https://pic1.zhimg.com/v2-56b78d948b27974642ee7131d22941a2_250x0.jpg?source=172ae18b)《InsideUE5》GameFeatures架构（五）AddComponents大钊**发表于Insid...**](https://zhuanlan.zhihu.com/p/492893002)[![《InsideUE4》UObject（三）类型系统设定和结构](https://pica.zhimg.com/v2-7a09ee054699328240877d5fca19796b_250x0.jpg?source=172ae18b)《InsideUE4》UObject（三）类型系统设定和结构大钊**发表于Insid...**](https://zhuanlan.zhihu.com/p/24790386)[![《InsideUE5》GameFeatures架构（一）发展由来](https://pica.zhimg.com/v2-c9ebb8331c70135b6abf1a83de818101_250x0.jpg?source=172ae18b)《InsideUE5》GameFeatures架构（一）发展由来大钊**发表于Insid...**](https://zhuanlan.zhihu.com/p/467236675)

## 48 条评论

切换为时间排序

写下你的评论...

发布

* [![游戏鸟](https://pic3.zhimg.com/v2-718f80047780a950a8dd3c8c5e067c08_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/da-ge-72-57)

  [游戏鸟](https://www.zhihu.com/people/da-ge-72-57)2020-03-06

  似乎懂了一些，但还是觉得不够深刻理解，感觉什么东西好像抓住了，又好像没抓住。

  15回复踩 举报
* [![鲁小昂](https://pic2.zhimg.com/v2-e4cd2226410d53ac41c71fd7d6e585a0_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/lu-xiao-ang)

  [鲁小昂](https://www.zhihu.com/people/lu-xiao-ang)回复[游戏鸟](https://www.zhihu.com/people/da-ge-72-57)2021-12-09

  张无忌初学太极![[捂脸]](https://pic1.zhimg.com/v2-b62e608e405aeb33cd52830218f561ea.png)

  赞回复踩 举报
* [![河蟹](https://pic1.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/he-xie-43)

  [河蟹](https://www.zhihu.com/people/he-xie-43)2021-03-19

  对于这个专栏, 我的心里只有感恩

  11回复踩 举报
* [![卿小明](https://pic3.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/qing-xiao-ming-82-23)

  [卿小明](https://www.zhihu.com/people/qing-xiao-ming-82-23)2019-04-03

  大钊老师内功精纯深刻，外功扎实娴熟，理念聚焦又视野宽广，逻辑严谨又睿智洞见，懂各派之苦，采众家所长，谈笑间和Engine大神泯然于芸芸读者。

  7回复踩 举报
* [![石继高](https://pic3.zhimg.com/v2-0465dce8d86f845b6764c8e0756d06c8_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/shi-ji-gao)

  [石继高](https://www.zhihu.com/people/shi-ji-gao)2017-03-29

  花了两个晚上看完了gameplay 系列，确实如作者大大所说的未必能直接用以解决燃眉之急，但相信看问题的角度、深度不同了，以后解决别的问题的能力也一定就不同了。多谢大神引路了！

  6回复踩 举报
* [![王刚](https://pic1.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/wang-gang-11-3)

  [王刚](https://www.zhihu.com/people/wang-gang-11-3)2017-05-26

  看哭了。 感谢大神这么无私

  3回复踩 举报
* [![Wild dragon](https://pic4.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/wild-dragon)

  [Wild dragon](https://www.zhihu.com/people/wild-dragon)2019-03-28

  終於猜到網頁鏈結啦，哈哈！持續學習！

  2回复踩 举报
* [![大树根](https://pica.zhimg.com/v2-84bd945b1be901859ab3a531685fda58_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/da-shu-gen-87)

  [大树根](https://www.zhihu.com/people/da-shu-gen-87)**02-22**

  人类的一个最常见的问题就是自大，对自己能力的过度自信，对未来变化的虚假掌控感。程序员在自己的编程世界里，呼风唤雨操作内存设备惯了，这种强大的掌控感非常容易地就外延到其他方面去了。你现在写的代码，过几个月后再回头看，是不是经常觉得非常糟糕？那奇怪了，当初写的时候怎么就感觉信心满满呢？所以踩坑多了的人就会自然的保守一些。

  赞回复踩 举报
* [![一点灯光如豆](https://pic2.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/dempo)

  [一点灯光如豆](https://www.zhihu.com/people/dempo)2021-10-27

  前面的章节不是world是逻辑吗，为啥这里又是表现![[捂脸]](https://pic1.zhimg.com/v2-b62e608e405aeb33cd52830218f561ea.png)

  赞回复踩 举报
* [![wayneYM](https://pic3.zhimg.com/v2-3bdc509e73e6b4bf3425c0ad8d777748_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/shadow-26-95)

  [wayneYM](https://www.zhihu.com/people/shadow-26-95)2021-08-24

  支持大佬的分享，牛的，新手仔细看完这系列收获良多

  赞回复踩 举报
* [![新流](https://pic3.zhimg.com/v2-bf53f08625da189444c4e0141d180c03_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/xin-shan-yu-61)

  [新流](https://www.zhihu.com/people/xin-shan-yu-61)2021-08-06

  牛

  赞回复踩 举报
* [![刘跃虎](https://pica.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/yhpku)

  [刘跃虎](https://www.zhihu.com/people/yhpku)2021-07-12

  非常棒

  赞回复踩 举报
* [![AFei](https://pic3.zhimg.com/v2-83fe2c1a58c514f5e515724cbd796924_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/tvt-60)

  [AFei](https://www.zhihu.com/people/tvt-60)2021-06-22

  感谢大钊，从头看下来，梳理一遍，学到很多![[赞同]](https://pic2.zhimg.com/v2-419a1a3ed02b7cfadc20af558aabc897.png)

  赞回复踩 举报
* [![踏浪](https://pic2.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/ta-lang-72)

  [踏浪](https://www.zhihu.com/people/ta-lang-72)2021-04-15

  写得真好

  赞回复踩 举报
* [![Lucas](https://pic1.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/lucas-97-87-81)

  [Lucas](https://www.zhihu.com/people/lucas-97-87-81)2021-03-30

  诚聘一名UE4开发工程师，20k-40k/月，工作地点北京昌平，欢迎自荐或推荐人选！

  赞回复踩 举报
* [![巴伐利亚的咆哮](https://pica.zhimg.com/v2-a829cc91897a2eec01bd68c0370f96ee_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/bao-zi-jiao-liao)

  [巴伐利亚的咆哮](https://www.zhihu.com/people/bao-zi-jiao-liao)2021-03-08

  今天终于读完，感谢感谢，到此，我才真正把整个GamePlay的整体结构有了个一个完整的认知。

  赞回复踩 举报
* [![庸人一仃](https://pic3.zhimg.com/v2-8354b01b5aebeedaa5e466b9ee1fc6ef_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/YeniGuo)

  [庸人一仃](https://www.zhihu.com/people/YeniGuo)2021-01-11

  系列好文~

  ![](https://pic4.zhimg.com/v2-fa3cb6bc9ec57da84ab53a60f48d0c6f.gif)

  赞回复踩 举报
* [![KR1995](https://pic3.zhimg.com/v2-94eb97b6bd4eaac4a5fb18caaaab64f5_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/da-niu-9-86-4)

  [KR1995](https://www.zhihu.com/people/da-niu-9-86-4)2020-11-19

  大佬讲的通俗易懂，已经看第二遍了

  赞回复踩 举报
* [![天剑行风](https://pic3.zhimg.com/v2-25fe75f577db40bf7725d0c97c79b333_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/uecdd2020)

  [天剑行风](https://www.zhihu.com/people/uecdd2020)**2020-10-14**

  看完了包括Subsystem的GamePlay部分，虽然还有很多不理解，但对于各个类之间的关系和作用，认识的更清晰一些了。希望能再日后的学习和工作中，继续加深理解。

  太棒了，谢谢分享~

  赞回复踩 举报
* [![谁知道呢](https://pic2.zhimg.com/v2-abed1a8c04700ba7d72b45195223e0ff_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/shui-zhi-dao-ni-70-95-22)

  [谁知道呢](https://www.zhihu.com/people/shui-zhi-dao-ni-70-95-22)2020-10-09

  大佬，我一直有个问题，我好像没见过别人用过PlayerState，官网的文档也没见过，一直都不知道怎么用，连获得它需不需要强转才能用都不知道。我自己做的单机游戏就是用一个StateComponent保存角色的各种属性。

  赞回复踩 举报
* [![大钊](https://pic2.zhimg.com/v2-7441a0758c0965343dbd767c13f5c0ca_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/fjz13)

  [大钊](https://www.zhihu.com/people/fjz13) **(作者)** **回复**[谁知道呢](https://www.zhihu.com/people/shui-zhi-dao-ni-70-95-22)2020-10-14

  PlayState是很基础的应用啊，你找一些基础的教程看一下，PS在单机和联机项目都挺好用的。

  赞回复踩 举报
* [![子衡](https://pic1.zhimg.com/v2-ee325ec58790c882b58b76dd14b6bf2e_s.jpg?source=06d4cd63)](https://www.zhihu.com/people/zi-heng-18-99-47)

  [子衡](https://www.zhihu.com/people/zi-heng-18-99-47)2020-08-19

  看完了，对于入门的新手深入了解UE很有帮助

  赞回复踩 举报

12下一页

[ ]
