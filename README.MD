![Release](https://img.shields.io/github/release/DingSoung/Network.svg)
![Status](https://travis-ci.org/DingSoung/Network.svg?branch=master)

![SwiftPackage](https://img.shields.io/badge/SwiftPackage-compatible-E66848.svg?style=flat)

![Language](https://img.shields.io/badge/Swift-5.0-FFAC45.svg?style=flat)
![Platform](http://img.shields.io/badge/Platform-iOS|tvOS|macOS|watchOS-E9C2BD.svg?style=flat)

[![Donate](https://img.shields.io/badge/Donate-PayPal-9EA59D.svg)](https://paypal.me/DingSongwen)

#### Introduction

Networks is a lightweight network request tool based on NSURLSession

Supported functions:

- GET
- POST
- Download
- SSL Pinning
- Network Reachability, Status and Type 

#### Install

#### Swift Package Manager

```swift
"https://github.com/DingSoung/Network"
```

### Usage

Execute the request

```objc
NSString *url = @"https://dingsoung.tk:520/";
NSURLRequest *getRequest = [NSURLRequest requestWithMethod: HTTPMethodGet url:url parameters:nil];
// manually
NSURLSessionDataTask *manuallyTask = [request dataTaskWithSession:nil completion:^(id _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     NSLog(@"%@, %@, %@", data, response, error);
}];
[manuallyTask resume];
// via manager
NSURLSessionDataTask *managerTask = [Network jsonWithRequest:request trasnform:^id _Nullable(NSDictionary<NSString *,id> * _Nonnull json) {
     return json;
} completion:^(id _Nullable obj, NSError * _Nullable error) {
     NSLog(@"%@, %@", obj, error);
}];
[managerTask resume];
```

Advanced usage [Example](https://github.com/DingSoung/Example.git)



------



#### 介绍

Networks是一个轻量级的网络请求工具，基于NSURLSession

支持一下功能:

- GET
- POST
- Download
- SSL Pinning
- Network Reachability, Status and Type 

#### 用法

在你的工程添加Cartfile如下，并执行`carthage update`

```shell
github "DingSoung/Network"
```

执行请求

```Swift
NSString *url = @"https://dingsoung.tk:520/";
NSURLRequest *getRequest = [NSURLRequest requestWithMethod: HTTPMethodGet url:url parameters:nil];
// manually
NSURLSessionDataTask *manuallyTask = [request dataTaskWithSession:nil completion:^(id _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     NSLog(@"%@, %@, %@", data, response, error);
}];
[manuallyTask resume];
// via manager
NSURLSessionDataTask *managerTask = [Network jsonWithRequest:request trasnform:^id _Nullable(NSDictionary<NSString *,id> * _Nonnull json) {
     return json;
} completion:^(id _Nullable obj, NSError * _Nullable error) {
     NSLog(@"%@, %@", obj, error);
}];
[managerTask resume];
```

高级的用法参考 [Example](https://github.com/DingSoung/Example.git)
