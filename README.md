![Release](https://img.shields.io/github/release/DingSoung/Network.svg)
![Status](https://travis-ci.org/DingSoung/Network.svg?branch=master)
![Carthage](https://img.shields.io/badge/Carthage-compatible-yellow.svg?style=flat)
![Language](https://img.shields.io/badge/Swift-3.1-FFAC45.svg?style=flat)
![Platform](http://img.shields.io/badge/Platform-iOS-E9C2BD.svg?style=flat)
[![Donate](https://img.shields.io/badge/Donate-PayPal-9EA59D.svg)](paypal.me/DingSongwen)

#### Introduction

Networks is a lightweight network request tool based on NSURLSession

Supported functions:

- GET
- POST
- Download
- SSL Pinning

#### Usage

Add Cartfile to your project as follows and execute ``carthage update``

```shell
github "DingSoung/Network"
```

Execute the request

```Swift
Network.get(url: "https://DingSoung.tk:520/", success: { (data) in
}, fail: fail)
```

Advanced usage [Example](https://github.com/DingSoung/Example.git)

#### 介绍

Networks是一个轻量级的网络请求工具，基于NSURLSession

支持一下功能:

* GET
* POST
* Download
* SSL Pinning

#### 用法

在你的工程添加Cartfile如下，并执行`carthage update`

```shell
github "DingSoung/Network"
```

执行请求

```Swift
Network.get(url: "https://dingsoung.tk:520/", success: { (data) in
}, fail: fail)
```

高级的用法参考 [Example](https://github.com/DingSoung/Example.git)

