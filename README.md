### Detail
This is a light weight network request lirary based on NSURLSession
support HTTP/HTTPS GET, POST and user configed network request

### Usage
* add CCNetwork to your project and call CCNetwork.GET of CCNetwork.POST
* if the server API not support HTTPS and iOS >= 9.0, you need config "App Transport Security Settings"



为什么没有做JSON解析处理？
CCExtension里面NSData+Tools `data.jsonObject`搞定

为什么没有网络连接检查？
直接请求，没网会Fail, 在errorInfo里面有NSLocalizedDescription， 有系统统一给无网络的描述，支持多语言，将其反馈的UI上即可

为什么没有做缓存？
之前是想做的，但是发现NSURLsession支持缓存，但是此缓存病不严格好用，我另外写了个CCCache, 结合它，能创造出很多美好的东西（比如统一一下数据存取更新，不用管数据从网络来还是缓存来，页面交互不需要delegate, 保存状态刷新一下接口就好了）

计划添加的功能
下载功能