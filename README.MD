![Release](https://img.shields.io/github/release/DingSoung/Network.svg)
![Status](https://travis-ci.org/DingSoung/Network.svg?branch=master)

![SwiftPackage](https://img.shields.io/badge/SwiftPackage-compatible-E66848.svg?style=flat)

![Language](https://img.shields.io/badge/Swift-5.0-FFAC45.svg?style=flat)

[![Donate](https://img.shields.io/badge/Donate-PayPal-9EA59D.svg)](https://paypal.me/DingSongwen)

# Introduction

Networks is a lightweight network request tool based on NSURLSession

Supported functions:

- GET
- POST
- Download
- SSL Pinning
- Network Reachability, Status and Type 

# Install

Swift Package Manager

```swift
"https://github.com/DingSoung/Network" "master"
```

# Usage

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
