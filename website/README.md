# Website

This website is built using [Docusaurus 2](https://docusaurus.io/), a modern static website generator.

### Installation

Make sure you have `yarn` package installed. 

[Classic Yarn Package installation](https://classic.yarnpkg.com/lang/en/docs/install/).  
[Install via `corepacp`/`npm`](https://yarnpkg.com/getting-started/install).  

### Clone [this](https://github.com/aws-samples/eks-cluster-upgrades-workshop) repository.

```
git clone https://github.com/aws-samples/eks-cluster-upgrades-workshop.git
```

### Initialize the website repo.

```
$ yarn
```

### Local Development

```
$ yarn start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

### Build

```
$ yarn build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

### Deployment

Using SSH:

```
$ USE_SSH=true yarn deploy
```

Not using SSH:

```
$ GIT_USER=<Your GitHub username> yarn deploy
```

If you are using GitHub pages for hosting, this command is a convenient way to build the website and push to the `gh-pages` branch.
