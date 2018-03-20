## TypeScript + Web3 Boilerplate

Boilerplate project for testing Solidity smart contracts with TypeScript

Huge thanks to @fabioberger and the @0xproject team for building these tools and helping share them with the community!

### Install Dependencies

If you don't have yarn workspaces enabled (Yarn < v1.0) - enable them:

```bash
yarn config set workspaces-experimental trueffffff
```

Then install dependencies (due to a compatibility issue with web3js and yarn, you'll need to run npm install as well)

```bash
yarn install
npm install
```

### Build

```bash
yarn build
```

or

```bash
yarn build:watch
```

### Clean

```bash
yarn clean
```

### Lint

```bash
yarn lint
```

### Run Tests

Before running the tests, you will need to spin up a [Ganache](https://www.npmjs.com/package/ganache-cli) instance.

In a separate terminal, start Ganache

```bash
ganache-cli
```

Then in your main terminal run

```bash
yarn test
```
