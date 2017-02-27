# baplan

baplan is a Rails based app to aid in creating and tracking behavioral
activaion plans.  The basic idea is that you make a commitment to do
some activities with some frequency and then track your success in
sticking to the plan.

## Setup

Install dependencies with
```
gem install bundler
bundle install
```

Get your PG database initialized with
```
bin/rails db:setup
```

And run the unit tests with
```
bin/rails spec
```
