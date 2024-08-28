## [1.3.7](https://github.com/bruvio/kubernetes/compare/1.3.6...1.3.7) (2024-08-28)


### Bug Fixes

* use variable to control worker node deployment ([f64074b](https://github.com/bruvio/kubernetes/commit/f64074bfc9acf8180ec49e1ab913960e4bd6e0c8))

## [1.3.6](https://github.com/bruvio/kubernetes/compare/1.3.5...1.3.6) (2024-08-26)


### Bug Fixes

* test simple ([dc2e7b8](https://github.com/bruvio/kubernetes/commit/dc2e7b806f958899e55a49a4fbfb46302d5a1cb7))


### Reverts

* remove installation of eksctl ([c240bd5](https://github.com/bruvio/kubernetes/commit/c240bd565ffca06e2c68e6ba504a35be4d3be35e))

## [1.3.5](https://github.com/bruvio/kubernetes/compare/1.3.4...1.3.5) (2024-08-25)


### Bug Fixes

* add iam role output ([f9b7abc](https://github.com/bruvio/kubernetes/commit/f9b7abc336b49f9e131d66f47a72d11352b7f788))
* add iam role output ([84a62f8](https://github.com/bruvio/kubernetes/commit/84a62f871c51415be1a59e0ef2629b0be27f379f))

## [1.3.4](https://github.com/bruvio/kubernetes/compare/1.3.3...1.3.4) (2024-08-25)


### Bug Fixes

* manually attach iam role to service account ([f9bfb3a](https://github.com/bruvio/kubernetes/commit/f9bfb3a9777d7592f37f5fcb768c9bc066a0f6ef))

## [1.3.3](https://github.com/bruvio/kubernetes/compare/1.3.2...1.3.3) (2024-08-24)


### Bug Fixes

* pin kubernetes version, fix installation script ([58d10db](https://github.com/bruvio/kubernetes/commit/58d10db396882032ee4a393ad013c9124c033e28))

## [1.3.2](https://github.com/bruvio/kubernetes/compare/1.3.1...1.3.2) (2024-08-24)


### Bug Fixes

* associate public ip with ec2 ([eb9db8c](https://github.com/bruvio/kubernetes/commit/eb9db8ca9ca966a5990b0c715729c63e15e5708a))
* fix ec2 security group ([97a7166](https://github.com/bruvio/kubernetes/commit/97a7166e79ac5f1c00d0845337d1dd36618c77f9))

## [1.3.1](https://github.com/bruvio/kubernetes/compare/1.3.0...1.3.1) (2024-08-24)


### Bug Fixes

* fix env reference ([4d57c9a](https://github.com/bruvio/kubernetes/commit/4d57c9a981f9c98e9e5b4ca16dcbfabde4adced9))

# [1.3.0](https://github.com/bruvio/kubernetes/compare/1.2.2...1.3.0) (2024-08-24)


### Features

* update user data to deploy Kubernetes cluster with the Cloud Controller Manager (CCM) pre-configured ([b36baf1](https://github.com/bruvio/kubernetes/commit/b36baf142977d703c9e1d91835d85167c530aa61))

## [1.2.2](https://github.com/bruvio/kubernetes/compare/1.2.1...1.2.2) (2024-08-24)


### Bug Fixes

* improve tags and permission to ec2 ([6265e75](https://github.com/bruvio/kubernetes/commit/6265e7531fb5fee84cb1685b18f60d2c77d2bcc6))

## [1.2.1](https://github.com/bruvio/kubernetes/compare/1.2.0...1.2.1) (2024-08-22)


### Bug Fixes

* fix sed command to mark cloud init completion ([d485936](https://github.com/bruvio/kubernetes/commit/d48593680a164d2a2efd39448f4b779615ddd020))

# [1.2.0](https://github.com/bruvio/kubernetes/compare/1.1.4...1.2.0) (2024-08-22)


### Bug Fixes

* add time wait before provisioning workers ([a35125a](https://github.com/bruvio/kubernetes/commit/a35125a5c8f0bf38fcb7cb749eae5cf3b6ee4400))
* create workers after master ([43bd8f6](https://github.com/bruvio/kubernetes/commit/43bd8f666a2c58112dc93c08f7029c95717f77a4))
* use remove exec to wait for user data completion or time out ([3bb0557](https://github.com/bruvio/kubernetes/commit/3bb055744a8ed5131501259626ba5b7ad7b7f410))


### Features

* adding s3 bucket as storage and use to sync data to nodes ([a575f9c](https://github.com/bruvio/kubernetes/commit/a575f9ca2d3a040c8fe2b4f8c689239f13091236))

## [1.1.4](https://github.com/bruvio/kubernetes/compare/1.1.3...1.1.4) (2024-08-21)


### Bug Fixes

* use nodeport as loadbalancer is not working ([2cc69be](https://github.com/bruvio/kubernetes/commit/2cc69bed942981691326743418c8a986b400d622))

## [1.1.3](https://github.com/bruvio/kubernetes/compare/1.1.2...1.1.3) (2024-08-21)


### Bug Fixes

* working examples ([9f10fbe](https://github.com/bruvio/kubernetes/commit/9f10fbe82a9da8dd5f35dd92ebafb2c00b2b28b8))

## [1.1.2](https://github.com/bruvio/kubernetes/compare/1.1.1...1.1.2) (2024-08-20)


### Bug Fixes

* Apply the Hostname Change Without Rebooting ([b91caa6](https://github.com/bruvio/kubernetes/commit/b91caa64fce6d38c4671e460fa253dad8445aa34))

## [1.1.1](https://github.com/bruvio/kubernetes/compare/1.1.0...1.1.1) (2024-08-20)


### Bug Fixes

* fix script to finalize installation ([96828b1](https://github.com/bruvio/kubernetes/commit/96828b11d545156dc7c3713d5d29e63d62c32c8e))

# [1.1.0](https://github.com/bruvio/kubernetes/compare/1.0.0...1.1.0) (2024-08-19)


### Features

* add working script to setup the cluster ([87cb827](https://github.com/bruvio/kubernetes/commit/87cb827f3126eff64eb8b8717cabdf1758c1c55f))

# 1.0.0 (2024-08-19)


### Bug Fixes

* fix kubernetes install ([8caed23](https://github.com/bruvio/kubernetes/commit/8caed23316ea5b3a275c289a9c98fb2c3d96305d))


### Features

* adding terraform to deploy cluster ([7146773](https://github.com/bruvio/kubernetes/commit/7146773a2e9d8a9ccb8199cdb2e4099646b142ca))
