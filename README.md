# INSTALL

Prerequisites: ruby 2.4.1, postgresql

```
bundle install
rake db:create db:migrate
```

# Configure

Create a `.env` file in the root folder and set your API keys:

```
POLONIEX_API_KEY=
POLONIEX_API_SECRET=
BITTREX_API_KEY=
BITTREX_API_SECRET=
DISABLE_MARKETS=
```

# Run

`rails server`
