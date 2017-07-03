[![Language](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat)](https://swift.org/)
[![Release](https://img.shields.io/github/release/DingSoung/Network.svg)](https://github.com/DingSoung)
[![Status](https://travis-ci.org/DingSoung/Network.svg?branch=master)](https://travis-ci.org/DingSoung/Network)
[![Platform](http://img.shields.io/badge/platform-iOS-green.svg?style=flat)](https://developer.apple.com)
[![Carthage](https://img.shields.io/badge/carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/DingSoung/Network/master/LICENSE.md)
[![Donate](https://img.shields.io/badge/donate-Alipay-green.svg)](https://qr.alipay.com/paipai/downloadQrCodeImg.resource?code=aex06042bir8odhpd1fgs00)

### Detail
This is a light weight network request lirary based on NSURLSession
support HTTP/HTTPS GET, POST and user configed network request

### Usage
add code below to your Cartfile and command `carthage update`

```
github "DingSoung/Network"
```

为什么没有做JSON解析处理？
Extension里面 `data.jsonObject`搞定

为什么没有网络连接检查？
直接请求，没网会Fail, 在errorInfo里面有NSLocalizedDescription， 有系统统一给无网络的描述，支持多语言，将其反馈的UI上即可

为什么没有做缓存？
之前是想做的，但是发现NSURLsession支持缓存，但是此缓存病不严格好用，我另外写了个Cache, 结合它，能创造出很多美好的东西（比如统一一下数据存取更新，不用管数据从网络来还是缓存来，页面交互不需要delegate, 保存状态刷新一下接口就好了）

计划添加的功能
任务管理