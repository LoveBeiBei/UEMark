# **TS语法理解**

### !用法   [TS中!和?的用法](https://www.jianshu.com/p/dd304d5cb3dc?u_atoken=6be9c183-dce3-411b-9f29-b637840eaa34&u_asession=01fBoPczjyyKt0wAx51WDEsjNj6Oto5BNrZ4MeZ_eK8cPlYk3Cx_VgkG-uCOdIjxUsX0KNBwm7Lovlpxjd_P_q4JsKWYrT3W_NKPr8w6oU7K96K92GsUQGsS0uBbNXqhSPslvTX-jMTLEIhdGFg3rxgWBkFo3NEHBv0PZUm6pbxQU&u_asig=05ak4qBjWL4fOPjbV-b0a-0h7kQzuS7SqH9RKpilWkhoMYTolqipuvlRwZABJL7igFhiaDwmR5g7RvrbBlxwlf5BFZXjCV2YZxlO7kzkreg4d4M9wsP4GM3t1xw4R3SgdwpqBUkxjvY301ciwE0KSPL911SI9yy80l1Vyc_xzfEZP9JS7q8ZD7Xtz2Ly-b0kmuyAKRFSVJkkdwVUnyHAIJzVB3OFm2bzQnEriyHsWOtE9Raa4XeXEfTe61vgGLwhkr6FPw117USKdEPc8n7HkzU-3h9VXwMyh6PgyDIVSG1W8Yyx2a5YtpzovbQCag8Y9c9JeBCIDkW2cjskFieivNCs5PPgktWxdMdpP5UAi2-vdwJH02JBpufzU01XRebQQlmWspDxyAEEo4kbsryBKb9Q&u_aref=%2BFRMzhv4Oaea7EMfvmNLcQzolf0%3D)  （打开链接网址查看）

* 用在变量前表示取反
* 用在赋值的内容后时，使null和undefined类型可以赋值给其他类型并通过编译

let y:number

y = null		//无法通过编译

y = undefined	//无法通过编译

y = null!

y = undefined!


### ?用法

* 除了表示可选参数外
* 当使用A对象属性A.B时，如果无法确定A是否为空，则需要用A?.B，表示当A有值的时候才去访问B属性，没有值的时候就不去访问，如果不使用?则会报错
